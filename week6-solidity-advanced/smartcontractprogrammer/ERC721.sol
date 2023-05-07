// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 參考 https://solidity-by-example.org/app/erc721/

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint);

    function ownerOf(uint tokenId) external view returns (address);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

// save transfer inside ERC721
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 { // 若沒有把所有 function 實作完成，該行就會出現錯誤 「Contract "ERC721" should be marked as abstract.」。
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // nft ID, nft owner
    mapping(uint => address) internal _ownerOf; // nft 擁有者
    mapping(address => uint) internal _balanceOf; // 某人有多少 nft
    // nft ID, spender address that was given approval to spend the nft on behalf of the owner
    mapping(uint => address) internal _approvals; // 某人將 NFT ID 批准給 spender address
    // owner 可能不只一個 nft, nft owner address, operator address that wiil be able to spend the owner's nft
    // 宣告為 public 是因為這是我們實作 IERC165 的 isApprovedForAll function
    mapping(address => mapping(address => bool)) public isApprovedForAll;  // true 代表 operator address 有權限可以花費 owner's nft

    // Function state mutability can be restricted to pure from view
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }
    // 因為 returns 有宣告 owner 變數，所以 function 內不用再次宣告 owner 變數，直接拿來用。
    function ownerOf(uint tokenId) external view returns (address owner) {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "owner = zero address");
    }

    // 批准給 operator 可以控制 owner's nft 或者移除此權限。
    function setApprovalForAll(address operator, bool _approved) external {
        isApprovedForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }
    // 批准 spender ( to address ) 有權可以控制 owner's tokenId of nft
    function approve(address to, uint tokenId) external {
        address owner = _ownerOf[tokenId]; // tokenId 擁有者
        // 既然限制 msg.sender 為 owner ，為何還要判斷 owner 是否有批准權獻給 msg.sender ？
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "not authorized");
        _approvals[tokenId] = to; // 需要先判斷在執行批准。
        emit Approval(owner, to, tokenId);
    }

    // 回傳 tokenId 分配給被批准的 operator address
    function getApproved(uint tokenId) external view returns (address operator) {
        require(_approvals[tokenId] != address(0), "token doesn't exist");
        return _approvals[tokenId];
    }

    // 再來實作 safeTransferFrom ，由於有兩種，且都會有重複使用的功能，因此先新增以下 internal function
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) internal view returns (bool) {
        return (
            spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]
        );
    }

    // 將會給 safeTransferFrom() 使用，所以須把 external 改為 public
    // 把 nft 從 from 移轉給 to
    function transferFrom(address from, address to, uint tokenId) public {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "to = zero address");
        require(_isApprovedOrOwner(from, to, tokenId), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        delete _approvals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    // 與 transferFrom() 一樣，唯一不同的是如果 to 是一個 contract 則需要呼叫 IERC721Receiver contract - onERC721Received function
    function safeTransferFrom(address from, address to, uint tokenId) external {
        transferFrom(from, to, tokenId);

        require(
            to.code.length == 0 ||
                // onERC721Received() 將會回傳 4 bytes of interface ID
                IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "") ==
                IERC721Receiver.onERC721Received.selector,
                "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external {
        transferFrom(from, to, tokenId);

        require(
            to.code.length == 0 ||
                // onERC721Received() 將會回傳 4 bytes of interface ID
                IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) ==
                IERC721Receiver.onERC721Received.selector,
                "unsafe recipient"
        );
    }

    // 上面宣告 mapping(address => mapping(address => bool)) public isApprovedForAll;
    // 就代表實作 isApprovedForAll() ，因為 public state variable 會自動產生與變數名稱一樣的 getter function 。
    // function isApprovedForAll(
    //     address owner,
    //     address operator
    // ) external view returns (bool);

    // ERC721 非必須實作的 function 但非常有用： mint(), burn()
    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "to = zero address");
        require(_ownerOf[tokenId] == address(0), "token exists");
        
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "token does not exist");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
}

contract MyNFT is ERC721 {
    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}

