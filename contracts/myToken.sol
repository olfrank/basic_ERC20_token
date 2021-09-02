
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";


contract MyToken is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MODIFY_CAP_ROLE = keccak256("MODIFY_CAP_ROLE");
    uint256 private _cap;

    constructor(string memory name, string memory symbol, uint256 cap_) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MODIFY_CAP_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function modifyCap(uint _newCap) public virtual returns(uint256){
        require(hasRole(MODIFY_CAP_ROLE, _msgSender()), "Must have the MODIFY_CAP_ROLE to modify cap" );
        _cap = _newCap;
        return _newCap;
    }
    
    
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
   
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);

        if(from == address(0)){
            require (totalSupply().add(amount) <= cap(), "cap exceeded");
        }
    }
}

    
    






/*
pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20Capped, Ownable {
    constructor() ERC20("MyToken", "MYTKN") ERC20Capped(100000) {

        _mint(msg.sender, 1000);
    }
}
*/
