// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title USDT Settlement Token
 * @notice Token ERC-20 independente para registro e liquidação interna.
 * @dev Não é emitido, garantido ou afiliado à Tether Limited.
 */
contract USDTSettlement is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public constant MAX_SUPPLY = 77_595_196 * 10 ** 6;

    string public projectLogoURI;
    address public immutable masterWallet;

    event LogoURIUpdated(string previousURI, string newURI);
    event ForeignTokenRecovered(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );

    constructor(
        address initialOwner,
        address initialReceiver,
        string memory initialLogoURI
    )
        ERC20("USDT Settlement Token", "USDS")
        Ownable(initialOwner)
    {
        require(initialOwner != address(0), "Owner cannot be zero");
        require(initialReceiver != address(0), "Receiver cannot be zero");

        masterWallet = initialReceiver;
        projectLogoURI = initialLogoURI;

        _mint(initialReceiver, MAX_SUPPLY);
    }

    /**
     * @notice Define 6 casas decimais.
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    /**
     * @notice Pausa transferencias, queimas e movimentacoes.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Retoma as movimentacoes.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Atualiza o URI público do logo do projeto.
     * @dev O logo não aparece automaticamente no Etherscan ou MetaMask.
     */
    function setProjectLogoURI(string calldata newLogoURI)
        external
        onlyOwner
    {
        string memory previousURI = projectLogoURI;
        projectLogoURI = newLogoURI;

        emit LogoURIUpdated(previousURI, newLogoURI);
    }

    /**
     * @notice Recupera outros tokens ERC-20 enviados por engano ao contrato.
     * @dev Não permite retirar o próprio token deste contrato.
     */
    function recoverForeignToken(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(token != address(this), "Cannot recover native token");
        require(token != address(0), "Invalid token");
        require(recipient != address(0), "Invalid recipient");

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                recipient,
                amount
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Token recovery failed"
        );

        emit ForeignTokenRecovered(token, recipient, amount);
    }

    /**
     * @dev Necessário para compatibilizar ERC20 e ERC20Pausable.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
