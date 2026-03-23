<template>
  <div class="wrapper">
    <div class="operation" style="width:600px">
      <span class="label">Course ID: </span><Input enter-button style="width: 160px" v-model="cid" @on-enter="handleSearch"/>
      <span class="label">Course Name: </span><Input enter-button style="width: 160px" v-model="cname"
                                            @on-enter="handleSearch"/>
    </div>
    <div class="operation" style="width:600px">
      <span class="label">Teacher Name: </span><Input enter-button style="width: 160px" v-model="tname"
                                            @on-enter="handleSearch"/>
      <span class="label">Teacher ID: </span><Input enter-button style="width: 160px" v-model="tid" @on-enter="handleSearch"/>
    </div>
    <Table class="operation" stripe border :columns="columns" :data="data1" size="large" placeholder="Search by criteria"></Table>
  </div>
</template>

<script>
  const tiptopMap = {
    '一': 1,
    '二': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '天': 7,
    '日': 7
  }
  var that = null
  export default {
    name: 'courseQuery',
    asyncData() {

    },
    data() {
      return {
        columns: [{
          'title': 'Course ID',
          'key': 'kh',
          'align': 'center'
        }, {
          'title': 'Course Name',
          'key': 'km',
          'align': 'center'
        }, {
          'title': 'Teacher ID',
          'key': 'gh',
          'align': 'center'
        }, {
          'title': 'Teacher Name',
          'key': 'xm',
          'align': 'center'
        }, {
          'title': 'Credits',
          'key': 'xf',
          'align': 'center'
        }, {
          'title': 'Class Time',
          'key': 'sksj',
          'align': 'center'
        }, {
          'title': 'Actions',
          'key': 'action',
          'fixed': 'right',
          'width': 100,
          'align': 'center',
          render(h, params) {
            return h('ButtonGroup', {
              props: {
                size: 'small'
              }
            }, [
              h('Button', {
                props: {
                  type: 'success',
                  icon: 'md-close'
                },
                on: {
                  click: () => {
                    // Check if course selection is open
                    that.$axios({
                      url: '/admin/courseManagement',
                      method: 'post',
                      data: {
                        op: 'queryOpen'
                      }
                    }).then((res) => {
                      if (res.data.open === 'open') {
                        // Check for duplicate cid and time conflicts
                        that.$axios({
                          url: '/student/courseCalendar',
                          method: 'post',
                          data: {
                            op: 'query'
                          }
                        }).then((res) => {
                          const data = res.data
                          if (!data.cid) {
                            data.cid = []
                            data.classTime = []
                          }
                          // Check for duplicate cid
                          for (let i = 0; i < data.cid.length; i++) {
                            if (params.row.kh === data.cid[i]) {
                              return that.$Notice.warning({
                                title: 'Notice',
                                desc: `You have already selected [${data.cid[i]}] "${data.cname[i]}" (${data.tname[i]}) this semester. You cannot select a course with the same Course ID again.`
                              })
                            }
                          }

                          function forEachClassUnit({ classTime }, func) {
                            // For each course
                            for (let i = 0; i < classTime.length; i++) {
                              let ct = classTime[i].split(' ')
                              // For each different time slot
                              if (!ct) {
                                ct = [classTime[i]]
                              }
                              for (let j = 0; j < ct.length; j++) {
                                const g = ct[j].match(/星期[一二三四五六七日天](\d+)-(\d+)/)
                                console.log(g)
                                if (!(g && g.length > 0 && g[1] >= 1 && g[1] <= 13 && g[2] >= 1 && g[2] <= 13 && parseInt(g[1]) <= g[2])) {
                                  throw new Error('Invalid class time format, example: 星期一11-13 星期五3-4')
                                }
                                const column = tiptopMap[ct[j].substring(2)[0]]
                                const arr = ct[j].substring(3).split('-')
                                let rowBegin = parseInt(arr[0]),
                                  rowEnd = parseInt(arr[1])
                                for (let k = rowBegin; k <= rowEnd; k++) {
                                  const stop = func(k, column, i, j) // Row number in timetable (starting from 1), column number (starting from 2), course index, time slot index
                                  if (stop) {
                                    return
                                  }
                                }
                              }
                            }
                          }

                          // Initialize timetable, leave 0 empty
                          const matrix = new Array(14)
                          for (let i = 0; i < 14; i++) {
                            matrix[i] = new Array(8)
                          }
                          try {
                            forEachClassUnit({ classTime: data.classTime }, (i, j) => {
                              matrix[i][j] = 1
                            })
                            // Check for class time conflicts
                            let invalid = false
                            let cIndex = -1
                            forEachClassUnit({ classTime: [params.row.sksj] }, (i, j, index) => {
                              if (matrix[i][j]) {
                                invalid = true
                                cIndex = index
                                return true
                              }
                              return false
                            })
                            if (invalid) {
                              return that.$Notice.warning({
                                title: 'Notice',
                                desc: `Class time conflicts with the selected "${data.cname[cIndex]}" [${data.classTime[cIndex]}]`
                              })
                            }
                            // Send confirmation
                            that.$Modal.confirm({
                              title: 'Confirm',
                              content: `Are you sure to enroll in "${params.row.km}"?`,
                              loading: true,
                              onOk: () => {
                                that.$axios({
                                  url: '/student/courseQuery',
                                  method: 'post',
                                  data: {
                                    cid: params.row.kh,
                                    classTime: params.row.sksj,
                                    tid: params.row.gh,
                                    term: that.selected,
                                    op: 'select'
                                  }
                                }).then((res) => {
                                  if (res.data.message === 'ok') {
                                    that.$Message.info('Enrolled successfully')
                                  } else {
                                    that.$Message.warning(res.data.message)
                                  }
                                  that.$Modal.remove()
                                })
                              },
                              onCancel: () => {
                              }
                            })
                          } catch (e) {
                            console.log(e)
                            that.$Notice.warning({
                              title: 'Notice',
                              desc: e.toString()
                            })
                          }
                        }).catch((err) => {
                          console.log(err)
                          that.$Notice.warning({
                            title: 'Notice',
                            desc: err.toString()
                          })
                        })
                      } else {
                        that.$Notice.warning({
                          title: 'Notice',
                          desc: 'Course enrollment is not open at this time'
                        })
                      }
                    }).catch((err) => {
                      console.log(err)
                      that.$Notice.warning({
                        title: 'Notice',
                        desc: err.toString()
                      })
                    })

                  }
                }
              }, 'Enroll')
            ])
          }
        }],
        data1: [],
        cid: '',
        cname: '',
        tid: '',
        tname: ''
      }
    },
    mounted() {
      that = this
    },
    methods: {
      handleSearch() {
        this.data1.length = 0
        this.$axios({
          url: '/student/courseQuery',
          method: 'post',
          data: {
            cid: this.cid.trim(),
            cname: this.cname.trim(),
            tid: this.tid.trim(),
            tname: this.tname.trim(),
            op: 'query'
          }
        }).then((res) => {
          console.log(res.data)
          const { cid, cname, credit, classTime, tid, tname } = res.data
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
              sksj: classTime[i]
            })
          }
        })
      }
    }
  }
</script>

<style scoped>

</style>
