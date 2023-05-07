// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { MyERC721Enumerable } from "../src/ERC721Compare.sol";
import { MyAzuki } from "../src/ERC721Compare.sol";

contract ERC721CompareTest is Test {
    // makeAddr() from forge-std/Std-Cheats.sol
    address owner = makeAddr("owner");
    address userA = makeAddr("userA");
    address userB = makeAddr("userB");
    address userC = makeAddr("userC");
    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");
    MyERC721Enumerable myERC721Enumerable;
    MyAzuki myAzuki;
    uint immutable mintQuantitiyA = 10;
    uint immutable mintQuantitiyB = 5;
    uint balanceOf_ERC721Enumerable_B;
    uint firstBalanceOf;
    uint tenthBalanceOf;

    function setUp() public {
        myERC721Enumerable = new MyERC721Enumerable();
        myAzuki = new MyAzuki();

        vm.startPrank(userA);
        myERC721Enumerable.mint(userA, 11);
        firstBalanceOf = myERC721Enumerable.balanceOf(userA);
        myERC721Enumerable.mint(userA, 23);
        myERC721Enumerable.mint(userA, 35);
        myERC721Enumerable.mint(userA, 45);
        myERC721Enumerable.mint(userA, 98);
        myERC721Enumerable.mint(userA, 100);
        myERC721Enumerable.mint(userA, 34);
        myERC721Enumerable.mint(userA, 119);
        myERC721Enumerable.mint(userA, 324);
        myERC721Enumerable.mint(userA, 56);
        tenthBalanceOf = myERC721Enumerable.balanceOf(userA);
        myAzuki.mint(mintQuantitiyA);
        vm.stopPrank();
        vm.startPrank(userB);
        myERC721Enumerable.mint(userB, 22);
        myERC721Enumerable.mint(userB, 33);
        myERC721Enumerable.mint(userB, 44);
        myERC721Enumerable.mint(userB, 55);
        myERC721Enumerable.mint(userB, 66);
        myAzuki.mint(mintQuantitiyB);
        balanceOf_ERC721Enumerable_B = myERC721Enumerable.balanceOf(userB);
        vm.stopPrank();
    }

    function testMint() public {
        uint balanceOf = myERC721Enumerable.balanceOf(userA);
        uint[] memory ownedTokenList = new uint[](balanceOf);
        // 查看 ERC721Enumerable owner's all token id
        console.logString(unicode"ERC271Enumerable 擁有者 userA 的所有 token id");
        for (uint i = 0; i < balanceOf; i++) {
            uint tokenId = myERC721Enumerable.tokenOfOwnerByIndex(userA, i);
            ownedTokenList[i] = tokenId;
            console.logUint(tokenId);
        }
        console.logString(unicode"ERC271A 擁有者 userA 的所有 token id");
        uint length = myAzuki.tokensOfOwner(userA).length;
        uint[] memory myAzukiList = myAzuki.tokensOfOwner(userA);
        // 查看 ERC721A owner's all token id
        for (uint i = 0; i < length; i++) {
            uint tokenId = myAzukiList[i];
            console.logUint(tokenId);
        }
        // ERC721A 是不是只要一次 mint 就更新 mint 數量的餘額
        assertEq(myAzuki.balanceOf(userA), mintQuantitiyA);
        // ERC721Enumerable 可以 mint 不連續 token id 的 NFT token
        bool ok = false;
        if (myAzukiList[9] == ownedTokenList[9]) {
            ok = true;
        }
        assertFalse(ok);
        // ERC721Enumerable 只能分次 mint 且狀態分次更新。
        assertGt(myAzuki.balanceOf(userA), firstBalanceOf);
        assertEq(firstBalanceOf, 1);
        assertEq(myAzuki.balanceOf(userA), tenthBalanceOf);
    }
    // 測試 ERC721Enumerable 可以不連續號碼的 mint token id
    // 測試成功，但為了讓程式碼能夠更少，把每一個測項需要的 mint 搬到 setUp ，這樣會造成 testFuzz 會 mint 到重覆的，所以先移除。
    // function testFuzzMintbyERC721Enumerale(uint256 tokenId) public {
    //     myERC721Enumerable.mint(userC, tokenId);
    //     assertEq(myERC721Enumerable.tokenOfOwnerByIndex(userC, 0), tokenId);
    // }

    function testTransfer() public {
        vm.startPrank(userA);
        // 取得 owner 所有 tokenId
        uint balanceOf_ERC721Enumerable = myERC721Enumerable.balanceOf(userA);
        uint[] memory ownedTokenList = new uint[](balanceOf_ERC721Enumerable);
        for (uint i = 0; i < balanceOf_ERC721Enumerable; i++) {
            uint tokenId = myERC721Enumerable.tokenOfOwnerByIndex(userA, i);
            ownedTokenList[i] = tokenId;
        }
        uint balanceOf_ERC721A = myAzuki.balanceOf(userA);
        uint[] memory myAzukiList = myAzuki.tokensOfOwner(userA);
        // 取得 owner 最後一個 tokenId
        uint256 lastTokenId_ERC721Enumerable = ownedTokenList[balanceOf_ERC721Enumerable - 1]; // 56
        uint256 lastTokenId_ERC721A = myAzukiList[balanceOf_ERC721A - 1]; // 9
        // 第 5 個 tokenId = 98
        myERC721Enumerable.safeTransferFrom(userA, userB, ownedTokenList[4]);
        // 第 5 個 tokenId = 4
        myAzuki.safeTransferFrom(userA, userB, myAzukiList[4]);
        vm.stopPrank();

        // ERC721Enumberable - 檢查賣掉的位置是否變為最後一個位置的 token id
        assertEq(lastTokenId_ERC721Enumerable, myERC721Enumerable.tokenOfOwnerByIndex(userA, 4));
        // ERC721Enumberable - 檢查最後一個位置是否刪除
        vm.expectRevert("ERC721Enumerable: owner index out of bounds");
        myERC721Enumerable.tokenOfOwnerByIndex(userA, balanceOf_ERC721Enumerable - 1);
        // ERC721Enumberable - balanceOf 是否少一個
        assertEq(myERC721Enumerable.balanceOf(userA), balanceOf_ERC721Enumerable - 1);
        // ERC721Enumberable - 賣掉的 token id 是否在 userB 最後一筆
        assertEq(myERC721Enumerable.tokenOfOwnerByIndex(userB,balanceOf_ERC721Enumerable_B), ownedTokenList[4]);
        // ERC721Enumberable - 賣掉的 token id 其擁有者是否變為 userB
        assertEq(myERC721Enumerable.ownerOf(ownedTokenList[4]), userB);

        // ERC721A - 賣掉的下一個 token's owner 是否為 userA
        assertEq(myAzuki.ownerOf(myAzukiList[5]), userA);
        // ERC721A - 賣掉的 token's owner 是否為 userB
        assertEq(myAzuki.ownerOf(myAzukiList[4]), userB);
        // vm.expectRevert(stdError.assertionError);
        // assertEq(myAzuki.tokensOfOwnerIn(userA, 4, 5)[0], 0);
        // ERC721A - owner’s balanceOf 是否少一個
        assertEq(myAzuki.balanceOf(userA), balanceOf_ERC721A - 1);
        // ERC721A - 最後一個 index 的 token id 是否有改變
        uint[] memory lastNew = myAzuki.tokensOfOwnerIn(userA, balanceOf_ERC721A - 1, balanceOf_ERC721A);
        assertEq(lastNew[0], lastTokenId_ERC721A);
        // ERC721A - new owner 有此 token id 且根據排序，排在第一個。
        uint[] memory myAzukiList_B = myAzuki.tokensOfOwner(userB);
        assertEq(myAzukiList_B[0], myAzukiList[4]);
    }

    function testApprove() public {
        // approve 第 6 顆
        vm.startPrank(userA);
        console.log("approve");
        uint approveTokenId_ERC721Enumerable = myERC721Enumerable.tokenOfOwnerByIndex(userA,5);
        uint approveTokenId_ERC721A = myAzuki.tokensOfOwner(userA)[5];
        console.logUint(myERC721Enumerable.tokenOfOwnerByIndex(userA,5));
        console.logUint(myAzuki.tokensOfOwner(userA)[5]);
        myERC721Enumerable.approve(userB, myERC721Enumerable.tokenOfOwnerByIndex(userA,5)); // 100
        myAzuki.approve(userB, myAzuki.tokensOfOwner(userA)[5]); // 5
        vm.stopPrank();
        // spender is userB
        assertEq(myERC721Enumerable.getApproved(myERC721Enumerable.tokenOfOwnerByIndex(userA,5)), userB);
        assertEq(myAzuki.getApproved(myAzuki.tokensOfOwner(userA)[5]), userB);

        // transfer from userA to userC by userB
        vm.startPrank(userB);
        myERC721Enumerable.safeTransferFrom(userA, userC, myERC721Enumerable.tokenOfOwnerByIndex(userA,5));
        myAzuki.safeTransferFrom(userA, userC, myAzuki.tokensOfOwner(userA)[5]);
        vm.stopPrank();
        // ownership to userC
        console.log("owner");
        console.logAddress(myERC721Enumerable.ownerOf(approveTokenId_ERC721Enumerable));
        console.logAddress(myAzuki.ownerOf(approveTokenId_ERC721A));
        assertEq(myERC721Enumerable.ownerOf(approveTokenId_ERC721Enumerable), userC);
        assertEq(myAzuki.ownerOf(approveTokenId_ERC721A), userC);
    }
}