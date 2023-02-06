# CSC-staking

- CSC testnet:
  + Chain id: 53
  + Native token: CETT
  + RPC: https://testnet-rpc.coinex.net

Token testnet address: 0x614EA1546f54192c713d2fcC516E4a74cF282fA0
new: 0xc52111412C12bC3aE61A68ff8f1312A85fd97A35
   

1. Smart contract cho stake token của dự án sẽ gồm 3 contract
  - 0x359F4ed0764F878a5BF71A615686fc277cD610C6
  - 0x264bB08fb82ee8f3C996370369E2b63b143d264F
  - 0xf60B965989d4FfE0cE929a66c2048013118a9eA7
  
  new

  - 0xfe3Fbc9e9ec27839b8E60bf0948b7103eBBFf09F
  - 0x337130bd32f9f8DD886B5380104AAEe8e3215B44
  - 0x98De7AF9968FCD4e6e5B831B8d191eeD8811B4e5
  
  
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

LP token: 0x8e1f1352336B948a37C702fc289483A975699EEe
staking contract: 0x95B2c798Ca8fEe06d8c6d317A5ef54C9544614f2

- Biến:
  + LPstakedBalance(address => uint256): số token 1 address đang stake.
  + reward(address => uint256): số token thưởng của 1 address.
- Hàm:
  + stakeLP(uint256 amount): dùng để stake.
  + withdrawLP(uint256 amount): dùng unstake.
  + claimReward(): rút token reward.

3. Stake CET vào validator:
 - reward contract: 0xBe56AF235eb4FD1932aC0F32518b472C8d7D9eEb
 - hàm claimReward() dùng để claim reward.

- Staking contract: 0x0000000000000000000000000000000000001000
- Hàm getStakingInfo(staker, validator=0xebeDB77b225C461f4823dA085F087Dc591302937): thông tin về số token đang stake của user.
- Hàm stake(amount, validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): stake CET
- Hàm unstake(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): unstake CET (phần này cần 1 cửa sổ thông báo là sau khi unstake 72h mới được rút token).
- Hàm withdrawStaking(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): rút phần unstake 
