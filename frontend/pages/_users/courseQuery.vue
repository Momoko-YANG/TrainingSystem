<template>
  <div class="wrapper">
    <div class="operation" style="width:600px">
      <span class="label">Course ID:</span><Input enter-button style="width: 160px" v-model="cid" @on-enter="handleSearch"/>
      <span class="label">Course Name:</span><Input enter-button style="width: 160px" v-model="cname"
                                            @on-enter="handleSearch"/>
    </div>
    <div class="operation" style="width:600px">
      <span class="label">Teacher Name:</span><Input enter-button style="width: 160px" v-model="tname"
                                            @on-enter="handleSearch"/>
      <span class="label">Teacher ID:</span><Input enter-button style="width: 160px" v-model="tid" @on-enter="handleSearch"/>
    </div>
    <Table class="operation" stripe border :columns="columns" :data="data1" size="large" placeholder="Search by any field"></Table>
  </div>
</template>

<script>
  import { iterateScheduleUnits } from '~/assets/js/schedule'

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
                    //判选课开放
                    that.$axios({
                      url: '/admin/courseManagement',
                      method: 'post',
                      data: {
                        op: 'queryOpen'
                      }
                    }).then((res) => {
                      if (res.data.open === 'open') {
                        //判cid重复, 判时间冲突
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
                          //判cid重复
                          for (let i = 0; i < data.cid.length; i++) {
                            if (params.row.kh === data.cid[i]) {
                              return that.$Notice.warning({
                                title: 'Warning',
                                desc: `You have already selected [${data.cid[i]}] ${data.cname[i]} (${data.tname[i]}) for this term. Duplicate course IDs are not allowed.`
                              })
                            }
                          }

                          //初始化课表，把0空出来
                          const matrix = new Array(14)
                          for (let i = 0; i < 14; i++) {
                            matrix[i] = new Array(8)
                          }
                          try {
                            iterateScheduleUnits(data.classTime, (i, j) => {
                              matrix[i][j] = 1
                            })
                            //查看上课时间是否重复
                            let invalid = false
                            let cIndex = -1
                            iterateScheduleUnits(params.row.sksj, (i, j, index) => {
                              if (matrix[i][j]) {
                                invalid = true
                                cIndex = index
                                return true
                              }
                              return false
                            })
                            if (invalid) {
                              return that.$Notice.warning({
                                title: 'Warning',
                                desc: `This class time conflicts with ${data.cname[cIndex]} [${data.classTime[cIndex]}].`
                              })
                            }
                            //发送提示
                            that.$Modal.confirm({
                              title: 'Confirm',
                              content: `Do you want to enroll in ${params.row.km}?`,
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
                                    that.$Message.info('Enrollment successful')
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
                              title: 'Warning',
                              desc: e.toString()
                            })
                          }
                        }).catch((err) => {
                          console.log(err)
                          that.$Notice.warning({
                            title: 'Warning',
                            desc: err.toString()
                          })
                        })
                      } else {
                        that.$Notice.warning({
                          title: 'Warning',
                          desc: 'Course enrollment is currently closed.'
                        })
                      }
                    }).catch((err) => {
                      console.log(err)
                      that.$Notice.warning({
                        title: 'Warning',
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
