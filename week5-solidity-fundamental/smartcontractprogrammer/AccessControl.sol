// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 分配 role 給 account 以決定是否可以呼叫 function

contract AccessControl {
    // 參數宣告 indexed 以利過濾並快速找到 log
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    // role => account => bool
    // 為何 role 不宣告 string 而是 bytes ， 是因為要把 role name 進行 hash ，不管 role name 多長，都固定儲存為 bytes32 。
    // 這樣做可以節省 gas
    mapping(bytes32 => mapping(address => bool)) public roles;
    // 重新計算不需要存在鏈上，這樣 gas 會比較少。
    // 常數名稱慣例全部大寫 - week3 - cryptozombies
    // ADMIN hash value: 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // USER hash value: 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));
    // 為了得到 hash value 暫時將上面兩個 variable 宣告為 public ，得到後再改回 public 。
    // 為何要這樣做，因為 function inputs 都是 bytes32 ，也就是編碼後的 hash value 。
    // bytes32 public constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // bytes32 public constant USER = keccak256(abi.encodePacked("USER"));

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _; // execute the rest of function whitch attached the modifier
    }

    // 如果沒有 constructor 初始化 role ( ADMIN role => msg.sender ) ，將不會有任何人具有 ADMIN 可以呼叫 grantRole function 。
    constructor() {
        _grantRole(ADMIN, msg.sender); // 這也是為何 _granRole 要宣告成 internal 而不是 private
    }

    // 授予 role 權限 => updates roles mapping
    // 不使用 private 而是使用 internal 是避免有繼承合約或者其他 function 需要使用到此 grant function 。
    // 使用 underline 跟 public function 避免撞名
    function _grantRole(bytes32 _role, address _account) internal {
        // grant role to this account
        // for this role and for this account, set ie equal to true.
        // 此段因為有兩個地方會使用到，所以獨立成一個 function ，避免程式碼重複。
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    // 只有 msg.sender 具有 ADMIN role 才可以呼叫此 function
    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }
}

// deploy and execute steps
// 1. 查看 msg.sender 是否具有 ADMIN role
// 2. 具有 ADMIN role's account ，授權給其他 account 具有 USER role 。
// 3. 查看 User role's account 是否具有 USER role
// 4. 移除 User role's account 的 USER role
// 5. 查看是否仍具有 USER role