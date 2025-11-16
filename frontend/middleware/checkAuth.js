import { getUserInfoFromToken } from 'assets/js/tokenTools'

export default function({ store, redirect }) {
  // 用以引导游客、已登录用户到不同界面
  if (store.state.token) {
    const info = getUserInfoFromToken(store.state.token)
    return redirect('/' + info.identity)
  } else {
    console.log("!logout")
    return redirect('/login')
  }
}
