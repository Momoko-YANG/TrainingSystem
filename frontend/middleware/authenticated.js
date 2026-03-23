export default function ({ store, redirect }) {
  // Only authenticated users can access this; if the user is not authenticated, redirect to login
  if (!store.state.token) {
    return redirect('/login')
  }
}
