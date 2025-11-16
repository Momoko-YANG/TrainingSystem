<template>
  <div class="login">
    <div class="filter">
      <div class="SysTitle">
        教務管理システム
        <div class="login-box">
          <Input v-model="username" style="margin-bottom: 10px" size="large" prefix='md-person' placeholder="ユーザー名"/>
          <Input v-model="password" type="password" style="margin-bottom: 10px" prefix="md-lock" size="large"
                 placeholder="パスワード"/>
          <ButtonGroup size="large" style="margin-top:10px">
            <div>
              <Button size="large" type="warning">
                パスワードを忘れた？
              </Button>
              <Button size="large" type="primary" :loading="loading" @click="login">
                ログイン
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
        title: 'ログイン'
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
            this.$store.commit('setToken', res.data.token) // Vuexにトークンを保存（クライアントサイドレンダリング用）
            this.$cookies.set('token', res.data.token, { expires: 1 }) // Cookieにトークンを保存（サーバーサイドレンダリング用）
            this.$router.push('/')
          } else {
            this.$Notice.warning({
              title: 'ログイン失敗',
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
