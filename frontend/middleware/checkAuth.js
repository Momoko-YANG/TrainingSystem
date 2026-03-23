import { getUserInfoFromToken } from 'assets/js/tokenTools'

export default function({ store, redirect }) {
  // Redirect guests and logged-in users to different pages
  if (store.state.token) {
    const info = getUserInfoFromToken(store.state.token)
    return redirect('/' + info.identity)
  } else {
    console.log("!logout")
    return redirect('/login')
  }
}
