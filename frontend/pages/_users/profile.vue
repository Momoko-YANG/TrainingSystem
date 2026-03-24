<template>
  <Collapse v-model="whichCollapse" accordion>
    <Panel name="1">
      My Profile
      <p slot="content">
        <Tag color="blue">{{idLabel}}</Tag>
        {{profile.id||profile.tid||profile.aid}}
      </p>
      <p slot="content" v-if="profile.name||profile.tname">
        <Tag color="orange">Name</Tag>
        {{profile.name||profile.tname}}
      </p>
      <p slot="content" v-if="profile.gender">
        <Tag color="green">Gender</Tag>
        {{profile.gender}}
      </p>
      <p slot="content" v-if="profile.dname">
        <Tag color="cyan">Department</Tag>
        {{profile.dname}}
      </p>
      <p slot="content" v-if="profile.grade">
        <Tag color="geekblue">Year</Tag>
        {{profile.grade}}
      </p>
      <p slot="content" v-if="profile.birthplace">
        <Tag color="magenta">Birthplace</Tag>
        {{profile.birthplace}}
      </p>
      <p slot="content" v-if="profile.phone">
        <Tag color="purple">Phone</Tag>
        {{profile.phone}}
      </p>
    </Panel>
  </Collapse>
</template>

<script>
  export default {
    name: 'profile',
    async asyncData({ params, app }) {
      let idLabel = ''
      let ret = {}
      if (params.users === 'student') {
        idLabel = 'Student ID'
      } else if (params.users === 'teacher') {
        idLabel = 'Employee ID'
      } else {
        idLabel = 'Admin ID'
      }
      ret.idLabel = idLabel
      await app.$axios({
        url: `/${params.users}/profile`
      }).then((res) => {
        console.log(res.data)
        ret.profile = { ...res.data }
      })
      return ret
    },
    data: () => ({
      whichCollapse: '1',
      idLabel: 'Student ID',
      profile: {
        name: '',
        id: '',
        dep: '',
        type: ''
      }
    })
  }
</script>

<style scoped>

</style>
