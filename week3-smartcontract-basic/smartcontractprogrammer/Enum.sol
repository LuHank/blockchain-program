// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 場景：紀錄購買者的訂單狀態。
contract Enum {
    enum Status { // shipping status
        None, // default value - no shipping request
        Pendign, // getting process (訂單運送處理中)
        Shipped, // 訂單運送中
        Completed, // 訂單運送完成
        Rejected, // 訂單被拒絕
        Canceled // 訂單取消
    }

    Status public status;

    struct Order { // how to combine with other data types
        address buyer;
        Status status;
    }

    Order[] public orders;

    function get() view external returns (Status) { // how to return an enum from a function
        return status; // 將會回傳 enum index number 例如 None 會回傳 0, Pending 會回傳 1, Shipped 會回傳 2, 依此類推。
    }
    // function 參數需指定 enum index number 。
    function set(Status _status) external { // how to take enum as input and set status to the enum from the input
        status = _status; // update state variable 
    }

    function ship() external { // how to update an enum to a specific enum
        status = Status.Shipped;
    }

    function reset() external { // reset the enum to default value - enum first item
        delete status; // value = 0
    }

}