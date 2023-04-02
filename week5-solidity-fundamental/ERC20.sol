// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
// function visibility - external 比 public 便宜
// EIP20 function 都是 public - https://eips.ethereum.org/EIPS/eip-20
// OpenZeppelin 實作也都是 public - https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    // https://academy.binance.com/zt/articles/an-introduction-to-erc-20-tokens
    // 為何不直接 transfer 就好，而要使用以下複雜方式？
    // approve: 可以限制智能合約從您餘額提現的代幣數量。若沒有此函數，您就會面臨合約失效（或遭利用） 並竊取您所有資金的風險。
    // allowance: allowance 可以與 approve 一起使用。當您獲得管理代幣的合約權限時，您可能會使用此函數來查看還能夠提現的代幣數量。例如，如果您申購時用掉了 20 枚核准代幣中的 12 枚，調用 allowance 函數應該會傳回 8 的總額。
    // allowance 場景：託管、遊戲、拍賣。例如 buyer 允許 seller contract function 轉移 buyer 授權的 token 數量，這樣 seller contract 就知道 buyer 是否付款成功。
    // transferFrom: 您可以授權某個人 – 或另一份合約 – 代表自己轉帳資金。可能用例包括：支付基於申購的服務，且您不想為此每天/每週/每月手動傳送付款。相反地，您會讓程式幫您完成所有操作。
    // 為何 function 都要宣告為 external 而不是 public ？
    // 1. holder call approve function that spender on his behalf spend his erc20 token
    // 2. holder call allowance that approve spender on behalf transfer on his behalf
    // 3. approved spender call transferFrom function that transfer from the holder's erc20 token to recipient
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool); // erc20 token holder 允許 spender 花費他的 erc20 token

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 is IERC20 { // 實作 IERC20 的功能
    uint public totalSupply; // 追蹤 token totoalSupply - mint 會增加，burn 會減少。
    mapping(address => uint) public balanceOf; // 使用者有多少 token
    // 1st address - tokens owner, 2nd address spender (ex. contract with the allowance)
    mapping(address => mapping(address => uint)) public allowance; // owner approve spender to spend a certain amount
    // erc20 token metadata: name, symbol, decimal
    string public name = "Test";
    string public symbol = "TEST";
    uint8 public decimal = 18; // 10^18 = 1 erc20 token
    // 如果沒有實作以下 function 會出現編譯錯誤 - Contract "ERC20" should be marked as abstract.
    function transfer(address recipient, uint amount) external returns (bool) {
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
        // solidity 0.8 以後 overflow and underflow 都會導致錯誤
        // 所以如果 sender(holder) 沒有 approve msg.sender(spender) ，則此程式碼就會報錯。
        allowance[sender][msg.sender] -= amount; 

        // 當我們執行 transferFrom 就需要更新餘額 - holder(sender) and recipient ， spender(msg.sender) 只負責執行轉幣行為。
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 雖然 mint 及 burn 不屬於 ERC20 Standard ，但大部分 ERC20 token contract 都有使用。
    // 需要 mint 才能 create token
    // 只有合約擁有者或者發出提交(限定權限)才能 mint
    // 此案例是範例，所以直接允許 msg.sender 都可以 create 任何數量的 tokens 。
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount; // 才有 new token 可以轉 。
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount); // address(0) 轉移 the amount of new token 給 msg.sender
        // address(0) 代表甚麼？
    }

    // 銷毀流通的 token
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}