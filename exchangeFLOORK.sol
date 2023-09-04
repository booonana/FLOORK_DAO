// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title Exchange contract from FLOORK to USDC
/// forked from https://github.com/ibuygovernancetokens/Incubator-DAO/tree/main/contracts
contract ExchangeFLOORK is Ownable, Pausable {
	using SafeERC20 for IERC20;

	/// @notice FLOORK
	IERC20 public immutable tokenFLOORK;

	/// @notice USDC
	IERC20 public immutable tokenUSDC;

	/// @notice Exchange Rate
	uint256 public exchangeRate;

	/// @notice emitted when exchange FLOORK to USDC
	event Exchange(address indexed user, uint256 amount, uint256 value);
	event ExchangeRateSet(uint256 exchangeRate);

	//
	// @notice constructor
	// @param _tokenFLOORK FLOORK token address
	// @param _tokenUSDC USDC token address
	// @param _exchangeRate exchange rate of USDC per FLOORK value with 6 decimals
	//
	constructor(IERC20 _tokenFLOORK, IERC20 _tokenUSDC, uint256 _exchangeRate) Ownable() {
		tokenFLOORK = _tokenFLOORK;
		tokenUSDC = _tokenUSDC;
		exchangeRate = _exchangeRate;
		_pause();
	}

	function pause() external onlyOwner {
		_pause();
	}

	function unpause() external onlyOwner {
		_unpause();
	}

	/**
	 * @notice Exchange rate value with 6 decimals, example 6029100 = $6.0291
	 * @param _exchangeRate amount of USDC per FLOORK (USD / FLOORK)
	 */
	function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
		exchangeRate = _exchangeRate;
		emit ExchangeRateSet(_exchangeRate);
	}

	/**
	 * @notice Withdraw IERC20 token
	 * @param _token address for withdraw
	 * @param _amount to withdraw
	 */
	function withdrawAssets(IERC20 _token, uint256 _amount) external onlyOwner {
		_token.safeTransfer(owner(), _amount);
	}

	/**
	 * @notice Exchange from FLOORK to USDC
	 * @param _amount of FLOORK exchanged
	 */
	function exchange(uint256 _amount) external whenNotPaused {
		tokenFLOORK.safeTransferFrom(_msgSender(), address(this), _amount);
		uint256 _value = _amount * exchangeRate / 1e18; // @note 1e18 * 1e6 / 1e18 = 1e6
		tokenUSDC.safeTransfer(_msgSender(), _value);

		emit Exchange(_msgSender(), _amount, _value);
	}
}
