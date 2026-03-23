<template>
  <div class="wrapper">
    <Form class="operation">
      <FormItem label="Semester">
        <Select
          v-model="selected"
          style="width:200px"
          placeholder="Select Semester"
          @on-change="handleSelectChange"
        >
          <Option v-for="term of terms" :value="term" :key="term">{{term}}</Option>
        </Select>
      </FormItem>
    </Form>
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
    name: 'scoreQuery',
    async asyncData({ app }) {
      const data1 = []
      let terms = null
      let selected = ''
      await app.$axios({
        url: '/student/scoreTable'
      }).then(async (res) => {
        terms = res.data.term.term
        if (!terms) {
          return
        }
        res.data.term.isCurrent.some((x, index) => {
          if (x === 'yes') {
            selected = terms[index]
            return true
          }
          return false
        })
        await app.$axios({
          url: '/student/scoreTable',
          method: 'post',
          data: {
            term: selected
          }
        }).then((res) => {
          const { cid, cname, credit, score, tid, tname } = res.data
          if (!cid) {
            return
          }
          for (let i = 0; i < cid.length; i++) {
            data1.push({
              kh: cid[i],
              km: cname[i],
              gh: tid[i],
              xm: tname[i],
              xf: credit[i],
              cj: score[i]
            })
          }
        })
      })
      return {
        data1,
        terms,
        selected
      }
    },
    data() {
      return {
        selected: '',
        columns: [{
          'title': 'Course ID',
          'key': 'kh',
          'align': 'center'
        },
          {
            'title': 'Course Name',
            'key': 'km',
            'align': 'center'
          },
          {
            'title': 'Teacher ID',
            'key': 'gh',
            'align': 'center'
          },
          {
            'title': 'Teacher Name',
            'key': 'xm',
            'align': 'center'
          },
          {
            'title': 'Credits',
            'key': 'xf',
            'align': 'center'
          },
          {
            'title': 'Score',
            'key': 'cj',
            'align': 'center'
          }],
        data1: [],
        terms: []
      }
    },
    methods:{
      handleSelectChange(term) {
        this.data1.length = 0
        this.$axios({
          url: '/student/scoreTable',
          method: 'post',
          data: {
            term
          }
        }).then((res) => {
          const { cid, cname, credit, score, tid, tname } = res.data
          if (!cid) {
            return
          }
          for (let i = 0; i < cid.length; i++) {
            this.data1.push({
              kh: cid[i],
              km: cname[i],
              gh: tid[i],
              xm: tname[i],
              xf: credit[i],
              cj: score[i]
            })
          }
        })
      },
    }
  }
</script>

<style scoped>

</style>
