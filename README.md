# CSC-staking

- CSC testnet:
  + Chain id: 53
  + Native token: CETT
  + RPC: https://testnet-rpc.coinex.net

- Token testnet address: 0x614EA1546f54192c713d2fcC516E4a74cF282fA0
   

1. Smart contract cho stake token của dự án sẽ gồm 3 contract
  - 0x359F4ed0764F878a5BF71A615686fc277cD610C6
  - 0x264bB08fb82ee8f3C996370369E2b63b143d264F
  - 0xf60B965989d4FfE0cE929a66c2048013118a9eA7
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
- Biến:
  + LPstakedBalance(address => uint256): số token 1 address đang stake.
  + reward(address => uint256): số token thưởng của 1 address.
- Hàm:
  + stakeLP(uint256 amount): dùng để stake.
  + withdrawLP(uint256 amount): dùng unstake.
  + claimReward(): rút token reward.
