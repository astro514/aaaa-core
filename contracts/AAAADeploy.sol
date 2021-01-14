// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;
import "./modules/ConfigNames.sol";

interface IConfigable {
	function setupConfig(address config) external;
}

interface IConfig {
	function developer() external view returns (address);

	function platform() external view returns (address);

	function factory() external view returns (address);

	function mint() external view returns (address);

	function token() external view returns (address);

	function share() external view returns (address);

	function governor() external view returns (address);

	function initialize(
		address _platform,
		address _factory,
		address _mint,
		address _token,
		address _share,
		address _governor
	) external;

	function initParameter() external;

	function setWallets(bytes32[] calldata _names, address[] calldata _wallets) external;

	function changeDeveloper(address _developer) external;

	function setValue(bytes32 _key, uint256 _value) external;
}

interface IAAAAMint {
	function sync() external;
}

interface IAAAAShare {
	function setShareToken(address _shareToken) external;
}

interface IAAAAToken {
	function initialize() external;
}

interface IAAAAFactory {
	function countPools() external view returns (uint256);

	function allPools(uint256 index) external view returns (address);

	function isPool(address addr) external view returns (bool);

	function getPool(address lend, address collateral) external view returns (address);

	function createPool(address _lendToken, address _collateralToken) external returns (address pool);
}

interface IAAAAPlatform {
	function updatePoolParameter(
		address _lendToken,
		address _collateralToken,
		bytes32 _key,
		uint256 _value
	) external;
}

contract AAAADeploy {
	address public owner;
	address public config;
	modifier onlyOwner() {
		require(msg.sender == owner, "OWNER FORBIDDEN");
		_;
	}

	constructor() public {
		owner = msg.sender;
	}

	function setupConfig(address _config) external onlyOwner {
		require(_config != address(0), "ZERO ADDRESS");
		config = _config;
	}

	function changeDeveloper(address _developer) external onlyOwner {
		IConfig(config).changeDeveloper(_developer);
	}

	function createPool(address _lendToken, address _collateralToken) public onlyOwner {
		IAAAAFactory(IConfig(config).factory()).createPool(_lendToken, _collateralToken);
	}

	function changeMintPerBlock(uint256 _value) external onlyOwner {
		IConfig(config).setValue(ConfigNames.MINT_AMOUNT_PER_BLOCK, _value);
		IAAAAMint(IConfig(config).mint()).sync();
	}

	function setShareToken(address _shareToken) external onlyOwner {
		IAAAAShare(IConfig(config).share()).setShareToken(_shareToken);
	}

	function updatePoolParameter(
		address _lendToken,
		address _collateralToken,
		bytes32 _key,
		uint256 _value
	) external onlyOwner {
		IAAAAPlatform(IConfig(config).platform()).updatePoolParameter(_lendToken, _collateralToken, _key, _value);
	}
}
