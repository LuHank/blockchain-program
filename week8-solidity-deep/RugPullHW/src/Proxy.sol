// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

contract Proxy {
  function _delegate(address _implementation) internal virtual {
    assembly {
      // 複製 msg.data 存入記憶體
      // calldatacopy(t, f, s) - copy s bytes from calldata at position f to mem at position t
      // 從 f 位置複製 s bytes calldata 到記憶體 t 位置
      calldatacopy(0, 0, calldatasize())
      // delegatecall(g, a, in, insize, out, outsize)
      // a: implementation contract address
      // in: 從記憶體哪個位置
      // insize: 資料大小
      // out, outsize: 並不知道資料回傳的大小所以設定 0,0
      // return value (result): 1 - 成功, 0 - 失敗 (例如 gas 不夠)
      let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
      // 複製回傳的 data
      // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
      // 從 f 位置複製 s bytes returndata 到記憶體 t 位置
      returndatacopy(0, 0, returndatasize())
      switch result
      // revert(p, s)
      // 從記憶體 p 位置回傳 returndatasize
      case 0 { revert(0, returndatasize()) }
      // return(p, s)
      // 將 return data 從記憶體位置 0 取出並回傳
      default { return(0, returndatasize()) }
    }
  }
}