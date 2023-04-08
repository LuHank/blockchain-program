
pragma solidity ^0.4.25; // 這是為了防止未來的編譯器版本可能引入會破壞您的代碼的更改。

// 建立一個 ZombieFactory 合約 - 可以建立殭屍軍團
// 1. 工廠維護一個資料庫，包含軍團所有殭屍。
// 2. 會有一個 function 可以生成殭屍。
// 3. 每一個殭屍會有隨機且唯一的外貌。

// 殭屍外貌(特徵)將會建立在殭屍 DNA - 16-digits ( 16 位 ) 整數。 DNA 不同部位將會對應不同的殭屍特徵。
//     - 1-2 碼 Head Gene 代表殭屍頭型 - 7 種
//       雖然 2 碼可以有 100 種，但先簡單化為 7 種。
//       如何決定是哪一種？ => 83 % 7 + 1 = 7 代表第 7 種頭型。
//     - 3-4 碼 Eye Gene 代表殭屍眼睛類型 - 11 種
//     - 5-6 碼 Shirt Gene - 6 種
//     - 7-8 碼 Skin Color Gene - 360 種
//     - 9-10 碼 Eye Color Gene - 360 種
//     - 11-12 碼 Clothes Color Gene - 360 種

// Solidity application 都是由 contract 包起來，包含 variables, functions 。


      contract ZombieFactory {

          uint dnaDigits = 16;
          uint dnaModulus = 10 ** dnaDigits;

          struct Zombie {
              string name;
              uint dna;
          }

          Zombie[] public zombies;

      }