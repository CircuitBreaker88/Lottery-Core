pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface Lottery {
    function buy(uint256 _price, uint8[4] memory _numbers) external;
}

contract LotteryRewardProxy {
    using SafeERC20 for IERC20;

    Lottery public lottery;
    IERC20 public pay;
    address public adminAddress;

    constructor(
        Lottery _lottery,
        IERC20 _pay,
        address _admin
    ) public {
        lottery = _lottery;
        pay = _pay;
        adminAddress = _admin;
    }

    event Inject(uint256 amount);
    event Withdraw(uint256 amount);

    uint8[4] private nullTicket = [0,0,0,0];

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    function inject(uint256 _amount) external onlyAdmin {
        pay.safeApprove(address(lottery), _amount);
        lottery.buy(_amount, nullTicket);
        emit Inject(_amount);
    }

    function adminWithdraw(uint256 _amount) external onlyAdmin {
        pay.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(_amount);
    }

    function setAdmin(address _adminAddress) external onlyAdmin {
        adminAddress = _adminAddress;
    }

    function setLottery(Lottery _lotteryAddress) external onlyAdmin {
        lottery = _lotteryAddress;
    }

}