# CSC-staking

- CSC testnet:
  + Chain id: 53
  + Native token: CETT
  + RPC: https://testnet-rpc.coinex.net

Token testnet address: 0x39445481C1bFA15990CbCdE3ACCD5f1514A89B4F

 

1. Smart contract cho stake token của dự án sẽ gồm 3 contract
  - 0xed71A42bE581A0872D6e77813aa613A4cEaB10fD
  - 0x9C8c1093770dFBf6326684b7b32A4766c89a52a9
  - 0xefab0e2679255B100AF15DcAD4F2449dBa43261a
 
  
  Mỗi contract sẽ có apy và thời gian khóa khác nhau, một số biến và hàm cơ bản sẽ sử dụng như sau:
  - Biến:
    + totalStaked(int): tổng số token đang stake trong contract. 
    + limit(int): số token tối đa được staking trong contract.
    + apy(int): lãi suất theo năm (ví dụ 300 là 300%/năm).
    + lockTime(int): thời gian khóa rút. (trong thời gian khóa rút vẫn có thể được rút reward).
    + totalStakedByAccount(address => uint256): số token mà 1 address đang stake.
  - Hàm:
    + Các hàm để lấy thông tin cho user(không tốn gas)
      + totalReward(address _address): trả về số token reward hiện tại của 1 địa chỉ.
      + amountClaimable(address _address): trả về số lượng token mà địa chỉ ví có thể unstake.
    + Các hàm để thực hiện các chức năng stake
      + claim_reward(): dùng để claim reward.
      + stake(uint256 amount): dùng để stake.
      + multiUnstake(uint256 amount): unstake với số lượng là amount.

2.Smart contract cho stake LP token:

LP token: 

staking contract: 

  - Biến:
    + LPstakedBalance(address => uint256): số token 1 address đang stake.
    + reward(address => uint256): số token thưởng của 1 address.
  - Hàm:
    + stakeLP(uint256 amount): dùng để stake.
    + withdrawLP(uint256 amount): dùng unstake.
    + claimReward(): rút token reward.


3. Stake CET vào validator:

Reward contract: 0x872bdb4adA093440a9CC9F442a162780D5DF42a9
  - hàm claimReward() dùng để claim reward.


Staking contract: 0x0000000000000000000000000000000000001000
  - Hàm getStakingInfo(staker, validator=0xebeDB77b225C461f4823dA085F087Dc591302937): thông tin về số token đang stake của user.
  - Hàm stake(amount, validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): stake CET
  - Hàm unstake(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): unstake CET (phần này cần 1 cửa sổ thông báo là sau khi unstake 72h mới được rút token).
  - Hàm withdrawStaking(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): rút phần unstake 
