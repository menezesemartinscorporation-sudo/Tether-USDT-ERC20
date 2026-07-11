// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title USDT Settlement Token
 * @notice ERC-20 criado para representar um registro digital de liquidação
 * declarado pelo proprietário do projeto.
 *
 * @dev O contrato registra informações fornecidas pelo proprietário.
 * Dados bancários externos não podem ser tecnicamente confirmados pela
 * blockchain sem um oráculo ou atestação independente.
 */
contract USDTSettlement is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    Ownable
{
    using SafeERC20 for IERC20;

    uint8 private constant TOKEN_DECIMALS = 6;

    uint256 public constant MAX_SUPPLY =
        77_595_196 * 10 ** TOKEN_DECIMALS;

    // USD 77.517.600,80 representado em centavos.
    uint256 public constant DECLARED_FIAT_AMOUNT_CENTS =
        7_751_760_080;

    uint256 public constant DECLARED_TOKEN_AMOUNT =
        77_595_196 * 10 ** TOKEN_DECIMALS;

    address public immutable masterWallet;

    string public settlementReference;
    string public settlementCurrency;
    string public settlementNetwork;
    string public projectLogoURI;
    string public supportingDocumentURI;

    bytes32 public supportingDocumentHash;

    bool public settlementDeclared;
    uint256 public declarationTimestamp;

    event SettlementDeclared(
        string indexed reference,
        uint256 fiatAmountCents,
        uint256 tokenAmount,
        address indexed masterWallet,
        uint256 timestamp
    );

    event ProjectLogoURIUpdated(
        string previousURI,
        string newURI
    );

    event SupportingDocumentUpdated(
        string documentURI,
        bytes32 documentHash
    );

    event ForeignTokenRecovered(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );

    constructor(
        address initialOwner,
        address initialReceiver,
        string memory initialLogoURI,
        string memory initialDocumentURI,
        bytes32 initialDocumentHash
    )
        ERC20("USDT Settlement Token", "USDS")
        Ownable(initialOwner)
    {
        require(
            initialOwner != address(0),
            "Initial owner cannot be zero"
        );

        require(
            initialReceiver != address(0),
            "Initial receiver cannot be zero"
        );

        masterWallet = initialReceiver;

        settlementReference = "SANBR2026M10533303";
        settlementCurrency = "USD";
        settlementNetwork = "Ethereum ERC-20";

        projectLogoURI = initialLogoURI;
        supportingDocumentURI = initialDocumentURI;
        supportingDocumentHash = initialDocumentHash;

        settlementDeclared = true;
        declarationTimestamp = block.timestamp;

        _mint(initialReceiver, MAX_SUPPLY);

        emit SettlementDeclared(
            settlementReference,
            DECLARED_FIAT_AMOUNT_CENTS,
            DECLARED_TOKEN_AMOUNT,
            initialReceiver,
            block.timestamp
        );

        emit SupportingDocumentUpdated(
            initialDocumentURI,
            initialDocumentHash
        );
    }

    function decimals()
        public
        pure
        override
        returns (uint8)
    {
        return TOKEN_DECIMALS;
    }

    function declaredFiatAmount()
        external
        pure
        returns (
            uint256 wholeDollars,
            uint256 cents
        )
    {
        wholeDollars =
            DECLARED_FIAT_AMOUNT_CENTS / 100;

        cents =
            DECLARED_FIAT_AMOUNT_CENTS % 100;
    }

    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    function setProjectLogoURI(
        string calldata newLogoURI
    )
        external
        onlyOwner
    {
        string memory previousURI = projectLogoURI;

        projectLogoURI = newLogoURI;

        emit ProjectLogoURIUpdated(
            previousURI,
            newLogoURI
        );
    }

    function setSupportingDocument(
        string calldata newDocumentURI,
        bytes32 newDocumentHash
    )
        external
        onlyOwner
    {
        supportingDocumentURI = newDocumentURI;
        supportingDocumentHash = newDocumentHash;

        emit SupportingDocumentUpdated(
            newDocumentURI,
            newDocumentHash
        );
    }

    function recoverForeignToken(
        address token,
        address recipient,
        uint256 amount
    )
        external
        onlyOwner
    {
        require(
            token != address(0),
            "Invalid token address"
        );

        require(
            token != address(this),
            "Cannot recover this token"
        );

        require(
            recipient != address(0),
            "Invalid recipient"
        );

        IERC20(token).safeTransfer(
            recipient,
            amount
        );

        emit ForeignTokenRecovered(
            token,
            recipient,
            amount
        );
    }

    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
