// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// interface IWETH9 {
//     function deposit() external payable;
//     function withdraw(uint256 _amount) external;
// }

// interface IERC20 {
//     function totalSupply() external view returns (uint);

//     function balanceOf(address account) external view returns (uint);

//     function transfer(address recipient, uint amount) external returns (bool);

//     function allowance(address owner, address spender) external view returns (uint);

//     function approve(address spender, uint amount) external returns (bool); // erc20 token holder 允許 spender 花費他的 erc20 token

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint amount
//     ) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint value);
//     event Approval(address indexed owner, address indexed spender, uint value);
// }

// 不是一般發幣的 ERC-20 token
// contract Weth9 is IERC20, IWETH9 {
contract Weth9 {
    // uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    // 不是一般發幣的 ERC-20 token
    // string public name = "LayerKing"; // 代幣全名，目的增加可讀性。
    // string public symbol = "LKT";
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimal = 18;
    address owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Withdraw(address indexed from, address indexed to, uint value);
    event Log(string func, address sender, uint value, bytes data);

    // 不是一般發幣的 ERC-20 token，所以一開始應該是 0 且不須 owner 權限控制。
    // WETH 就是 1:1 ETH
    // 所以 Weth9 合約收到多少 ETH 就代表有多少 WETH
    // constructor(uint _totalSupply) payable {
    //     totalSupply = _totalSupply;
    //     owner = msg.sender;
    // }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(msg.sender != address(0), "transfer: msg.sender is the zero address");
        require(recipient != address(0), "transfer: recipient is the zero address");
        require(balanceOf[msg.sender] >= amount, "transfer: amount exceeds balance");
        // transfer 就要更新餘額
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        // 根據 ERC20 標準，當 transfer function 被呼叫，就需要觸發 Transfer event 。
        emit Transfer(msg.sender, recipient, amount); // 就像日誌一樣，在鏈上紀錄傳送者、接收者以及轉幣數量。
        return true; // means call this function was successful and no errors.
    }

    // 已經宣告 state variable - allowance 而且接下來會有 approve function
    // 會出現錯誤 Identifier already declare.
    // function allowance(address owner, address spender) external view returns (uint) {
    // }

    // msg.sender 將會 approve spender to spend some of his balance for the amount
    function approve(address spender, uint amount) external returns (bool) {
        require(msg.sender != address(0), "approve: msg.sender is the zero address");
        require(spender != address(0), "approve: spender is the zero address");
        require(balanceOf[msg.sender] >= amount, "approve: amount exceeds balance");
        allowance[msg.sender][spender] = amount; // msg.sender 允許 spender (ex. contract) 花費他的餘額 for the amount
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 只要 holder approve ，任何人都可以呼叫此 function 。
    // 此 function 是由 spender 呼叫的。
    // 須注意如果需要其他內部 contract 呼叫 transferFrom 則須設定為 public 而非 external
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require(sender != address(0), "transferFrom: sender is the zero address");
        require(recipient != address(0), "transferFrom: recipient is the zero address");
        require(balanceOf[sender] >= amount, "transferFrom: amount exceeds balance");
        // solidity 0.8 以後 overflow and underflow 都會導致錯誤
        // 所以如果 sender(holder) 沒有 approve msg.sender(spender) ，則此程式碼就會報錯。
        allowance[sender][msg.sender] -= amount; 

        // 當我們執行 transferFrom 就需要更新餘額 - holder(sender) and recipient ， spender(msg.sender) 只負責執行轉幣行為。
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // bchen: WETH 應該是不需要有一個 external mint function 我想，因為他就是要跟 ETH 1比1兌換，如果 owner 可以直接 mint 看起來挺危險
    // 雖然 mint 及 burn 不屬於 ERC20 Standard ，但大部分 ERC20 token contract 都有使用。
    // 需要 mint 才能 create token
    // 只有合約擁有者或者發出提交(限定權限)才能 mint
    // 此案例是範例，所以直接允許 msg.sender 都可以 create 任何數量的 tokens 。
    // function mint(uint amount) external {
    //     require(msg.sender == owner, "not authorized");
    //     balanceOf[msg.sender] += amount; // 才有 new token 可以轉 。
    //     totalSupply += amount;
    //     emit Transfer(address(0), msg.sender, amount); // address(0) 轉移 the amount of new token 給 msg.sender
    //     // address(0) 代表甚麼？
    // }

    // 將合約的 ETH 轉給 msg.sender 就代表 totalSupply 減少也代表銷毀 WETH 。
    // 銷毀流通的 token
    // function burn(uint amount) public {
    //     // balanceOf[msg.sender] -= amount;
    //     // totalSupply -= amount;
    //     emit Transfer(msg.sender, address(0), amount);
    // }

    function deposit() public payable { // 正常 interface 要有 override (^0.8.8 以後不用) https://docs.soliditylang.org/en/v0.8.20-docs/contracts.html#function-overriding
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        // totalSupply -= amount;
        emit Transfer(address(0), msg.sender, amount); 
    }

    // 可以用一行就取代，不需再另外寫一個 function
    // function sendViaTransfer(address payable _to, uint amount) public payable {
    //     // This function is no longer recommended for sending Ether.
    //     // _to.transfer(msg.value);
    //     _to.transfer(amount);
    // }

    function withdraw(uint amount) external {
        require(balanceOf[msg.sender] >= amount, "token balance not enough");
        // withdraw 提領代表使用者將 token 歸還 contract 而 contract 須歸還相對應的 ether
        // checks effects interactions pattern 先更改狀態，在進行外部的 external call
        balanceOf[msg.sender] -= amount;
        // totalSupply += amount;
        // 合約轉 ETH 給 msg.sender
        // sendViaTransfer(payable(msg.sender), amount);
        payable(msg.sender).transfer(amount);
        // balanceOf[msg.sender] -= amount;
        // totalSupply += amount;
        // burn(amount);
        emit Withdraw(msg.sender, address(0), amount);
    }

    // function getBalance() view public returns (uint)  {
    //     return address(this).balance;
    // }
    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        deposit();
        emit Log("receive", msg.sender, msg.value, "");
    }

}