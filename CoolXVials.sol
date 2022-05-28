// SPDX-License-Identifier: MIT

/*
 ___  ___  ________  ________  ___       ___  ___  ________      
|\  \|\  \|\   __  \|\   ___ \|\  \     |\  \|\  \|\   __  \     
\ \  \\\  \ \  \|\  \ \  \_|\ \ \  \    \ \  \\\  \ \  \|\  \    
 \ \   __  \ \  \\\  \ \  \ \\ \ \  \    \ \   __  \ \  \\\  \   
  \ \  \ \  \ \  \\\  \ \  \_\\ \ \  \____\ \  \ \  \ \  \\\  \  
   \ \__\ \__\ \_______\ \_______\ \_______\ \__\ \__\ \_____  \ 
    \|__|\|__|\|_______|\|_______|\|_______|\|__|\|__|\|___| \__\
                                                            \|__|
*/

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./PaymentSplitter.sol";
import "./CoolCats.sol";
import "./CloneX.sol";

contract CoolXVials is ERC1155, Ownable, PaymentSplitter {
    
  string public name;
  string public symbol;
  uint256 public maxSupply = 10000;
  uint256 public totalSupply = 0;
  uint256 public price = 0.1 ether;
  bool public paused = true;
  CoolCats public CC = CoolCats(0x1A92f7381B9F03921564a437210bB9396471050C);
  CloneX public CX = CloneX(0x49cF6f5d44E70224e2E23fDcdd2C053F30aDA28B);

  constructor(
    string memory _URI, 
    address[] memory _payees, 
    uint256[] memory _shares
    ) ERC1155("") PaymentSplitter(_payees, _shares) {
    name = "Cool X Vials";
    symbol = "CXV";
    _setURI(_URI);
  }

  function mint(address _to, uint256 _amount) public payable {
    require(totalSupply + _amount <= maxSupply && _amount > 0);

    if(msg.sender != owner()) {
      if(CC.walletOfOwner(_to).length > 0 || CX.tokensOfOwner(_to).length > 0) {
        require(balanceOf(_to, 1) + _amount <= 10);
      } else {
        require(balanceOf(_to, 1) + _amount <= 5);
      }
      require(!paused);
      require(msg.sender == _to);
      require(msg.value >= price * _amount);
    }

    _mint(_to, 1, _amount, "");
    totalSupply += _amount;
  }

  function burn(address account, uint256 _amount) public virtual {
    require(
      account == _msgSender() || isApprovedForAll(account, _msgSender()),
      "ERC1155: caller is not owner nor approved"
    );
    _burn(account, 1, _amount);
    totalSupply -= _amount;
  }

  function setURI(string memory _uri) external onlyOwner {
    _setURI(_uri);
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function setMaxSupply(uint256 _maxSupply) public onlyOwner {
    maxSupply = _maxSupply;
  }
}
    