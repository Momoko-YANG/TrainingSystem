<template>
  <div class="wrapper">
    <Table
      class="operation"
      stripe
      border
      :columns="columns"
      :data="data1"
    ></Table>
  </div>
</template>

<script>
  export default {
    name: 'scoreCollege',
    async asyncData({ app }) {
      let data1 = []
      await app.$axios({
        url: '/student/scoreCollege'
      }).then((res) => {
        const data = res.data
        if (data.message !== 'ok') {
          return
        }
        data1.push({
          xh: data.id,
          xm: data.name,
          pjcj: Number(data.score).toFixed(2),
          yx: data.did,
          zs: data.totalStudents,
          pm: data.rank,
          bfb: (Number(data.percentage) * 100).toFixed(1) + '%'
        })
      })
      return { data1 }
    },
    data() {
      return {
        selected: '',
        columns: [{
          'title': 'Student ID',
          'key': 'xh',
          'align': 'center'
        },
          {
            'title': 'Name',
            'key': 'xm',
            'align': 'center'
          },
          {
            'title': 'Average Score',
            'key': 'pjcj',
            'align': 'center'
          },
          {
            'title': 'Department',
            'key': 'yx',
            'align': 'center'
          },
          {
            'title': 'Class Size',
            'key': 'zs',
            'align': 'center'
          },
          {
            'title': 'Rank',
            'key': 'pm',
            'align': 'center'
          },
          {
            'title': 'Percentile',
            'key': 'bfb',
            'align': 'center'
          }],
        data1: []
      }
    }
  }
</script>

<style scoped>

</style>
