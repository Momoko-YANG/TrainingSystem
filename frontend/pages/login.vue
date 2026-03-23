<template>
  <div class="login">
    <div class="filter">
      <div class="SysTitle">
        Training Management System
        <div class="login-box">
          <Input v-model="username" style="margin-bottom: 10px" size="large" prefix='md-person' placeholder="Username"/>
          <Input v-model="password" type="password" style="margin-bottom: 10px" prefix="md-lock" size="large"
                 placeholder="Password"/>
          <ButtonGroup size="large" style="margin-top:10px">
            <div>
              <Button size="large" type="warning">
                Forgot Password?
              </Button>
              <Button size="large" type="primary" :loading="loading" @click="login">
                Login
              </Button>
            </div>
          </ButtonGroup>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { getUserInfoFromToken } from '~/assets/js/tokenTools'

  export default {
    name: 'login',
    middleware: 'anonymous',
    data: () => ({
      host: '',
      datalist: {},
      loading: false,
      username: '',
      password: ''
    }),
    head() {
      return {
        title: 'Login'
      }
    },
    methods: {
      login() {
        this.$axios({
          url: '/login',
          method: 'post',
          data: {
            id: this.username,
            password: this.password
          }
        }).then((res) => {
          if (res.data.message === 'ok') {
            this.$store.commit('setToken', res.data.token) // Save token to Vuex (for client-side rendering)
            this.$cookies.set('token', res.data.token, { expires: 1 }) // Save token to Cookie (for server-side rendering)
            this.$router.push('/')
          } else {
            this.$Notice.warning({
              title: 'Login Failed',
              desc: res.data.message
            })
          }
        })
      }
    }
  }
</script>

<style lang="scss" scoped>
  @import "./login";
</style>
