pragma solidity =0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/mining/IRbConsensus.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/TransferHelper.sol";
import "./MiningBase.sol";

//Invite mining
contract Rbinvite is MiningBase {
    using SafeMath for uint;//Security library
    //Individual cumulative redemption
    mapping(address => uint) public cumuRbt;
    //Use the total amount mined for display
    uint public digOutAmount;
    //RBTEX address
    address public _RBTEX;
    //Consensus address
    address public RbConsensus;
    //Collect all: for display
    uint public allReceived;
    //Exchange records for every piece of information
    event PurchaseRecord (address  User , uint indexed tokenAmount , uint indexed rbtAmount ,address indexed tokenAddress );

    //Coordinator parameter transfer
    constructor(
        address ex,
        address rbt,
        address rbConsensus,
        address Aadmin
    ) public {
        _RBTEX = ex;
        _Rbt = rbt;
        RbConsensus = rbConsensus;
        admin = Aadmin;
    }
    //RBTEX --> RBT exchange
    function getRBT(uint amount) public {
        (uint total,uint examount) = IRbConsensus(RbConsensus).exchangeRatio(msg.sender);
        TransferHelper.safeTransferFrom(_RBTEX, msg.sender, address(this), total);
        TransferHelper.safeTransfer(_Rbt, msg.sender, examount.div(5));
        //Data Display
        allReceived = allReceived.add(examount.div(5));
        digOutAmount = digOutAmount.add(examount);
        cumuRbt[msg.sender] += examount;
        emit PurchaseRecord(msg.sender , amount , examount ,_RBTEX );
    }

}
