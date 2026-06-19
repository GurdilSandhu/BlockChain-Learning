// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract parking {
    // IST is UTC + 5 hours 30 minutes (19,800 seconds)
    uint256 constant IST_OFFSET = 19800;

    enum Shift { nul, S1, S2 }

    struct TwoWheeler {
        uint Vnumber;
        Shift S1;
        uint entry;
        uint exit;
        uint time;
        uint amount;
        bool parked;
        string entryClock; // Stores formatted time like "8:05 AM"
        string exitClock;  // Stores formatted time like "5:06 PM"
    }

    mapping (uint => TwoWheeler) public vehicles;
    uint totalVs;

    // Helper to format raw timestamps to "HH:MM AM/PM" string in IST
    function formatToISTClock(uint256 _timestamp) internal pure returns (string memory) {
        uint256 istTime = _timestamp + IST_OFFSET;
        uint256 secondsPastMidnight = istTime % 86400;
        
        uint256 hour24 = secondsPastMidnight / 3600;
        uint256 minute = (secondsPastMidnight % 3600) / 60;

        string memory period = " AM";
        if (hour24 >= 12) {
            period = " PM";
        }

        uint256 hour12 = hour24 % 12;
        if (hour12 == 0) {
            hour12 = 12;
        }

        string memory minuteStr;
        if (minute < 10) {
            minuteStr = string(abi.encodePacked("0", uintToString(minute)));
        } else {
            minuteStr = uintToString(minute);
        }

        return string(abi.encodePacked(uintToString(hour12), ":", minuteStr, period));
    }

    // Helper to validate shifting hours based on current time
    function checkShiftValid(Shift _shift, uint256 _timestamp) internal pure returns (bool) {
        uint256 istTime = _timestamp + IST_OFFSET;
        uint256 secondsPastMidnight = istTime % 86400;
        uint256 currentMinutesSinceMidnight = secondsPastMidnight / 60;

        if (_shift == Shift.S1) {
            // Shift 1: 8:00 AM (480 mins) to 12:30 PM (750 mins)
            return (currentMinutesSinceMidnight >= 480 && currentMinutesSinceMidnight <= 750);
        } else if (_shift == Shift.S2) {
            // Shift 2: 2:00 PM (840 mins) to 7:00 PM (1140 mins)
            return (currentMinutesSinceMidnight >= 840 && currentMinutesSinceMidnight <= 1140);
        }
        return false;
    }

    // Helper to convert uint to string
    function uintToString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (uint8)(48 + (_i % 10));
            bstr[k] = bytes1(temp);
            _i /= 10;
        }
        return string(bstr);
    }

    function entry(uint Vnumber, uint _shift) public {
        require(vehicles[Vnumber].parked == false, "already parked");
        require(_shift == 1 || _shift == 2, "Invalid shift selected");
        
        Shift selectedShift = Shift(_shift);
        
        // Enforce Shift opening and closing windows
        require(checkShiftValid(selectedShift, block.timestamp), "Parking closed for this shift");

        totalVs++;
        
        vehicles[Vnumber] = TwoWheeler({
            Vnumber: Vnumber,
            S1: selectedShift,
            entry: block.timestamp,
            exit: 0,
            time: 0,
            amount: 0,
            parked: true,
            entryClock: formatToISTClock(block.timestamp),
            exitClock: ""
        });
    }

    function exit(uint Vnumber) public {
        TwoWheeler storage v = vehicles[Vnumber];
        require(v.parked == true, "Vehicle not parked");

        v.exit = block.timestamp;
        v.exitClock = formatToISTClock(block.timestamp);
        v.time = v.exit - v.entry;

        uint totalMinutes = v.time / 60;
        if (totalMinutes > 0) {
            uint intervals = totalMinutes / 10;
            if (totalMinutes % 10 > 0) {
                intervals += 1;
            }
            uint256 feePerInterval = 50000; 
            v.amount = intervals * feePerInterval;
        } else {
            v.amount = 50000 ;
        }

        v.parked = false;
    }
}
