import { getUserInfoFromToken } from 'assets/js/tokenTools'

export default function({ store, redirect }) {
  // Only guests can access this; if the user is authenticated, redirect to the home page
  if (store.state.token) {
    const info = getUserInfoFromToken(store.state.token)
    return redirect('/' + info.identity)
  }
}
