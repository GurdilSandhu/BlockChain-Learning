// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HundredToWord {

    string[20] units = [
        "Zero","One","Two","Three","Four",
        "Five","Six","Seven","Eight","Nine",
        "Ten","Eleven","Twelve","Thirteen",
        "Fourteen","Fifteen","Sixteen",
        "Seventeen","Eighteen","Nineteen"
    ];

    string[10] tens = [
        "","","Twenty","Thirty","Forty",
        "Fifty","Sixty","Seventy",
        "Eighty","Ninety"
    ];

    function NumToWord_rupees(uint num)public view returns(string memory){
        require(num <= 9999, "Only supports 0-9999");

        // 0 - 999
        if(num < 1000){
            return string(abi.encodePacked(convertBelowThousand(num)," Rupees"));
        }

        // 1000 - 9999
        uint th = num / 1000;
        uint rem = num % 1000;

        // Exact thousand
        if(rem == 0){
            return string(abi.encodePacked(units[th]," Thousand Rupees"));
        }

        return string( abi.encodePacked( units[th]," Thousand ",convertBelowThousand(rem)," Rupees"));
    }

    function convertBelowThousand(uint num)internal view returns(string memory){
        // 0 - 19
        if(num < 20){
            return units[num];
        }

        // 20 - 99
        if(num < 100){

            uint t = num / 10;
            uint u = num % 10;

            if(u == 0){
                return tens[t];
            }

            return string(abi.encodePacked( tens[t]," ", units[u]));
        }

        // 100 - 999
        uint h = num / 100;
        uint rem = num % 100;

        // Exact hundred
        if(rem == 0){
            return string(abi.encodePacked( units[h]," Hundred"));
        }

        return string(abi.encodePacked(units[h]," Hundred ",convertBelowThousand(rem)));
    }
}