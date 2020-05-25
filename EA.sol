
contract EA is EthcEvents{

struct  Player {

    uint256 pID;     
    address payable addr;      
    uint256 affId;    
    uint256 totalBet;  
    uint256 curGen;  
    uint256 curAff;  
    uint256 curgdRewad;
    string  inviteCode;
    uint256 lastBet;  
    uint256 lastReleaseTime;
    uint256 createTime;
    uint256 baseGen; 
    uint256 baseAff; 
    uint256 invites;
   
    
}

struct betHistory{
    
    uint256 betDateTime;
    uint256 pid;
    uint256 eth;
}

uint256 ethWei = 1 ether;

 uint256  private minbeteth_ = ethWei;
 uint256  genReleTime_ = 1 days;  
 mapping (uint256 => playerPot) public playerPot_;
 mapping (uint256 => betHistory) public betHistory_;
 mapping (uint256 => excellenceHistory) public exHistory_;
 
 


uint256 public excellencePot_;
uint256 public excellenceTime_ = 72 hours;
uint256 public excellenceStartTime_;
uint256 public excellenceRound_ = 1;

mapping (uint256 =>uint256[]) public drBestQue_; //[roudId -> 1\2\3]
mapping (uint256 =>mapping(uint256 =>uint256))    public drUserBet_; //[roudId -> user Pid]

uint256 public bxTotalCoin;
uint256 public bxStartTime_;
uint256 public bxTime_ = 48 hours;


uint256 public genRate_ = 800;
uint256 public betMax_ = 30 * ethWei;

modifier isActivated() {
    require(activated_ == true, "its not ready yet.  check ?eta in discord");
    _;
}

constructor()
public
{
    levelReward_[1] = levelReward(4,1,20,1);
    levelReward_[2] = levelReward(6,10,25,3);
    levelReward_[3] = levelReward(8,20,30,6);
 
    bxStartTime_ = now;
    excellenceStartTime_ = now;
    jsStatus_ = true;
    betId_ = 1;
   
}


function buyCore(uint256 _pID,uint256 _eth)
    isWithinLimits(msg.value)
    isCanBet(_pID,_eth)
    private
{
      
    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 
    plyr_[_pID].totalBet = _eth.add(plyr_[_pID].totalBet);
 
    
    plyrReward_[_pID].level = getLevel(plyr_[_pID].totalBet);
    plyr_[_pID].lastReleaseTime = now;
    setBetHistory(_pID,_eth);

   
}

function setBetHistory(uint256 _pID,uint256 _eth)
private{
    
    betHistory_[betId_].pid = _pID;
    betHistory_[betId_].betDateTime = now;
    betHistory_[betId_].eth = _eth;
    betId_++;
    
}


function getLevel (uint256 _betEth) 
public
view
returns(uint8 level) 
{
    uint8 _level = 0;
    if(_betEth>=11 * ethWei){
        _level = 3;

    }else if(_betEth>=6 * ethWei){
        _level = 2;

    }else if(_betEth>=1 * ethWei){
        _level = 1;

    }
    return _level;
}

function getDeepForUser(uint256 _pID)
view
public
returns(uint256 deep){
    
    deep = 0;
    
    if(plyr_[_pID].invites >=9){
        
         deep = 30;
    }else if(plyr_[_pID].invites >=7){
        
         deep = 20;   
    }else if(plyr_[_pID].invites >=5){
        
         deep = 10;   
    }else if(plyr_[_pID].invites >=3){
        
         deep = 5;   
    }else if(plyr_[_pID].invites >=1){
         deep = 1;
    }
    
    
}
function getGdLevel (uint256 xiaoqu) view  public returns(uint256 _gdLevel) {

         _gdLevel = 0;

        if(xiaoqu >=10000 * ethWei){
            
            _gdLevel= 4;
            
        }else if(xiaoqu >=2500 * ethWei){
            
            _gdLevel= 3;
            
        }else if(xiaoqu >=500 * ethWei){
            
            _gdLevel= 2;
            
        }else if(xiaoqu >=100 * ethWei){
            
            _gdLevel= 1;
        }

     }


function getPlayerlaByAddr (address _addr)
public
view
returns(uint256 _pID,uint256 _less,uint256 _totalGen,uint256 _totalAff,uint256 totalGenH,uint256 totalAffH,uint256 _baseGen,uint256 _baseAff)
{
    _pID = pIDxAddr_[_addr];
    
    (uint256 _gen,uint256 _aff,) = getUserRewardByBase(_pID);
    
    uint256 _ls =   plyr_[_pID].curGen + plyr_[_pID].curAff ;
    _ls = _ls + _gen + _aff + plyr_[_pID].curgdRewad; 
    
    _less = plyrReward_[_pID].reward > _ls ?plyrReward_[_pID].reward.sub(_ls):0;
    
    _totalGen  =  plyrReward_[_pID].totalGen + _gen;
    _totalAff = plyrReward_[_pID].totalAff + _aff;
   
    
    totalGenH =  plyrReward_[_pID].totalGen - plyrReward_[_pID].withDrawEdGen + _gen;
    totalAffH =  plyrReward_[_pID].totalAff - plyrReward_[_pID].withDrawEdAff + _aff;
   
    
    _baseGen = plyr_[_pID].baseGen;
    _baseAff = plyr_[_pID].baseAff;
    
    



}


function getPlayerlaById (uint256 _pID)
public
view
returns(uint256 affid,address addr,uint256 totalBet,uint256 level,uint256 _excellencepot,string memory inviteCode,string memory affInviteCode,uint256 _withdrawGdReward,uint256 _totalGdreward,uint256 _gdreward)
{
   require(_pID>0 && _pID < nextId_, "Now cannot withDraw!");
   
    affid =  plyr_[_pID].affId;
    addr  = plyr_[_pID].addr;
    totalBet = plyr_[_pID].totalBet;
    level = plyrReward_[_pID].level;
    
    _excellencepot = playerPot_[_pID].excellencepot;
    
    inviteCode = plyr_[_pID].inviteCode;
    affInviteCode =plyr_[plyr_[_pID].affId].inviteCode;
    _withdrawGdReward = plyrReward_[_pID].withDrawGdReward;
    _totalGdreward = plyrReward_[_pID].totalGdRewad;
    _gdreward = plyrReward_[_pID].totalGdRewad.sub(plyrReward_[_pID].withDrawGdReward);


}

function somethingmsg () 
public
view
returns(uint256 _minbeteth,uint256 _genReleTime)
{
    return(
     
        minbeteth_,
        genReleTime_
        );

}

function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _bxTotalCoin,uint256 _bxTime,uint256 _excellencepot,uint256 _excellenceStartTime,uint256  _excellenceRound,string memory _lastChampionInviteCode,uint256 _lastChampion)
{
    
    uint256 _exrid =   excellenceRound_> 1?excellenceRound_ - 1 :0;
    return
    (
        gBet_,
        gBetcc_,
        bxTotalCoin, 
        bxStartTime_ + bxTime_,
        excellencePot_,
        excellenceStartTime_ + excellenceTime_,
        excellenceRound_,
        plyr_[exHistory_[_exrid].championId].inviteCode,
        exHistory_[_exrid].champion
        
        
        
    );
}


function getExcellenceUser (uint256 _rid,uint256 _weizhi) 
public
view
returns(uint256 _pID,uint256 _totalBet,uint256 _baseAff) 
{
     _pID = drBestQue_[_rid][_weizhi];
    return
    (
        _pID,
        plyr_[_pID].totalBet,
        drUserBet_[_rid][_pID]

    );
}
function compareStr(string memory _str, string memory str) internal pure returns(bool) {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            return true;
        }
        return false;
    }

}
