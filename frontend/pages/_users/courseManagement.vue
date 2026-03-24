<template>
  <div class="wrapper">
    <Form class="operation">
      <FormItem label="Term">
        <Row type="flex" justify="space-between">
          <Select
            v-model="selected"
            style="width:200px"
            placeholder="Select a term"
            @on-change="handleSwitchTerm"
          >
            <Option v-for="term of terms" :value="term" :key="term">{{term}}</Option>
          </Select>
          <ButtonGroup>
            <Button type="primary" icon="md-add" size="large" @click="handleClickAddButton">
              Add Course
            </Button>
          </ButtonGroup>
        </Row>
      </FormItem>
      <FormItem>
        <Table
          stripe
          border
          :columns="columns"
          :data="data1"
        ></Table>
      </FormItem>
    </Form>

    <Drawer
      class="courseManagementDrawer"
      v-model="showDrawer"
      width="100"
      :mask-closable="false"
    >
      <div slot="header" style="overflow: unset;" class="ivu-drawer-header-inner">
        Course Schedule
        <Button
          size="small"
          type="dashed"
          icon="md-add"
          @click="handleClickAddScheduleButton"
          v-if="currentTerm===selected"
        ></Button>
      </div>
      <Row>
        <Col span="12">
          <Table
            class="calendarRaw"
            stripe
            border
            :columns="columns2"
            :data="data2"
            ref="calendarRaw"
          ></Table>
        </Col>
        <Col span="12">
          <Table
            class="calendar"
            disabled-hover
            border
            :columns="calendarColumns"
            :data="calendar"
            ref="calendar"
            :height="drawerContentHeight"
          ></Table>
        </Col>
      </Row>
    </Drawer>
    <Modal
      v-model="showModal"
      title="Add Course"
      @on-ok="handleAddCourse"
      :loading="modalLoading"
      :mask-closable="false"
    >
      <!--
          // cid,
          // cname,
          // credit,
          // dname
      -->
      <Form
        :model="form"
        label-position="right"
        :rules="ruleValidate"
        :label-width="80"
        style="padding:20px 30px 20px 15px"
        ref="form"
      >
        <FormItem label="Course ID" prop="cid">
          <Input v-model="form.cid"></Input>
        </FormItem>
        <FormItem label="Course Name" prop="cname">
          <Input v-model="form.cname"></Input>
        </FormItem>
        <FormItem label="Credits" prop="credit">
          <Input v-model="form.credit" number></Input>
        </FormItem>
        <FormItem label="Department" prop="dname">
          <Select v-model="form.dname" placeholder="Select a department">
            <Option :value="dep" v-for="dep in deps" :key="dep">{{dep}}</Option>
          </Select>
        </FormItem>
      </Form>
    </Modal>
    <Modal
      v-model="showModal2"
      title="Add Class Section"
      @on-ok="handleAddSchedule"
      :loading="modalLoading2"
      :mask-closable="false"
    >
      <!--
          // cid,
          // cname,
          // credit,
          // dname
      -->
      <Form
        :model="form2"
        label-position="right"
        :rules="ruleValidate2"
        :label-width="80"
        style="padding:20px 30px 20px 15px"
        ref="form2"
      >
        <FormItem label="Teacher" prop="tid">
          <Select v-model="form2.tid" placeholder="Select a teacher">
            <Option :value="t" v-for="(t,index) of allTid" :key="t">{{t}} - {{allTname[index]}}</Option>
          </Select>
        </FormItem>
        <FormItem label="Class Time" prop="classTime">
          <Input v-model="form2.classTime"></Input>
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
  import calendarColumnsMock from '~/assets/js/calendarColumnsMock'
  import { dayToColumnMap, iterateScheduleUnits, parseScheduleUnit } from '~/assets/js/schedule'

  let that

  const colorArray = ['#d50000', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#FF5722', '#795548', '#607D8B']
  export default {
    name: 'courseManagement',
    mixins: [calendarColumnsMock],
    async asyncData({ app }) {
      const data1 = []
      let terms = null
      let selected = ''
      await app.$axios({
        url: `/admin/courseManagement`
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
          url: `/admin/courseManagement`,
          method: 'post',
          data: {
            term: selected,
            op: 'select'
          }
        }).then((res) => {
          const { cid, cname, credit, dname, count } = res.data
          if (!cid) {
            return
          }
          for (let i = 0; i < cid.length; i++) {
            data1.push({
              cid: cid[i],
              cname: cname[i],
              credit: credit[i],
              dname: dname[i],
              count: count[i]
            })
          }
        })
      })
      return {
        data1,
        terms,
        selected,
        currentTerm: selected
      }
    },
    data() {
      return {
        currentTerm: '',
        allTname: [],
        allTid: [],
        columns: [{
          'title': 'Course ID',
          'key': 'cid',
          'align': 'center',
          'sortable': true
        }, {
          'title': 'Course Name',
          'key': 'cname',
          'align': 'center'
        }, {
          'title': 'Credits',
          'key': 'credit',
          'align': 'center'
        }, {
          'title': 'Department',
          'key': 'dname',
          'align': 'center'
        }, {
          'title': 'Sections',
          'key': 'count',
          'align': 'center',
          'sortable': true
        }, {
          'title': 'Actions',
          'key': 'action',
          'fixed': 'right',
          'width': 250,
          'align': 'center',
          render(h, params) {
            return h('ButtonGroup', {
              props: {
                size: 'default',
                shape: 'circle'
              }
            }, [
              h('Button', {
                props: {
                  type: 'primary',
                  icon: 'md-apps'
                },
                on: {
                  click: () => {
                    that.data2 = []
                    that.$axios({
                      url: '/admin/courseManagement',
                      method: 'post',
                      data: {
                        term: that.selected,
                        cid: params.row.cid,
                        op: 'calendar'
                      }
                    }).then((res) => {
                      (() => {
                        const { tid, tname, classTime } = res.data
                        if (!tid) {
                          return
                        }
                        for (let i = 0; i < tid.length; i++) {
                          const obj = {
                            tid: tid[i],
                            tname: tname[i],
                            classTime: classTime[i]
                          }
                          for (let k in params.row) {
                            if (params.row.hasOwnProperty(k)) {
                              obj[k] = params.row[k]
                            }
                          }
                          that.data2.push(obj)
                        }
                      })()
                        if (that.selected === that.currentTerm) {
                        that.columns2 = [...that.rawColumns2, {
                          'title': 'Actions',
                          'key': 'action',
                          'fixed': 'right',
                          'width': 100,
                          'align': 'center',
                          render(h, params) {
                            return h('ButtonGroup', {
                              props: {
                                size: 'small',
                                shape: 'circle'
                              }
                            }, [
                              h('Button', {
                                props: {
                                  type: 'warning',
                                  icon: 'md-trash'
                                },
                                on: {
                                  click: () => {
                                    that.$Modal.confirm({
                                      title: 'Confirm',
                                      content: `Delete the section ${params.row.tname} - ${params.row.cname}?`,
                                      loading: true,
                                      onOk: () => {
                                        that.$axios({
                                          url: '/admin/courseManagement',
                                          method: 'post',
                                          data: {
                                            cid: params.row.cid,
                                            tid: params.row.tid,
                                            op: 'deleteCourseSchedule'
                                          }
                                        }).then((res) => {
                                          that.$Modal.remove()
                                          if (res.data.message === 'ok') {
                                            that.$Message.info('Section deleted')
                                            that.data2.splice(params.index, 1)
                                            that.thisRow.count--
                                          } else {
                                            that.$Notice.warning({
                                              title: 'Warning',
                                              desc: res.data.message
                                            })
                                          }
                                        }).catch((err) => {
                                          that.$Modal.remove()
                                          that.$Notice.warning({
                                            title: 'Warning',
                                            desc: err.toString()
                                          })
                                        })
                                      },
                                      onCancel: () => {
                                      }
                                    })
                                  }
                                }
                              }, 'Delete')
                            ])
                          }
                        }]
                      } else {
                        that.columns2 = Object.assign([], that.rawColumns2)
                      }
                      that.showDrawer = true
                      that.$nextTick(() => {
                        that.renderCalendar({ raw: [] })
                        that.drawerContentHeight = document.querySelector('.courseManagementDrawer .ivu-drawer-body').offsetHeight
                      })
                    })
                    that.thisRow = params.row
                  }
                }
              }, 'Schedule'),
              h('Button', {
                props: {
                  type: 'warning',
                  icon: 'md-trash'
                },
                on: {
                  click: () => {
                    that.$Modal.confirm({
                      title: 'Confirm',
                      content: `Delete ${params.row.cname}? This course will be removed from all terms.`,
                      loading: true,
                      onOk: () => {
                        that.$axios({
                          url: '/admin/courseManagement',
                          method: 'post',
                          data: {
                            cid: params.row.cid,
                            op: 'deleteCourse'
                          }
                        }).then((res) => {
                          that.$Modal.remove()
                          if (res.data.message === 'ok') {
                            that.$Message.info('Course deleted')
                            that.data1.splice(params.index, 1)
                          } else {
                            that.$Notice.warning({
                              title: 'Warning',
                              desc: res.data.message
                            })
                          }
                        }).catch((err) => {
                          that.$Modal.remove()
                          that.$Notice.warning({
                            title: 'Warning',
                            desc: err.toString()
                          })
                        })
                      },
                      onCancel: () => {
                      }
                    })
                  }
                }
              }, 'Delete Course')
            ])
          }
        }],
        columns2: [],
        rawColumns2: [
          {
            'title': 'Course ID',
            'key': 'cid',
            'align': 'center'
          },
          {
            'title': 'Course Name',
            'key': 'cname',
            'align': 'center'
          },
          {
            'title': 'Teacher ID',
            'key': 'tid',
            'align': 'center'
          },
          {
            'title': 'Teacher Name',
            'key': 'tname',
            'align': 'center'
          },
          {
            'title': 'Credits',
            'key': 'credit',
            'align': 'center'
          },
          {
            'title': 'Class Time',
            'key': 'classTime',
            'align': 'center'
          }
        ],
        data1: [],
        data2: [],
        calendar: [{ time: '1' }, { time: '2' }, { time: '3' }, { time: '4' }, { time: '5' }, { time: '6' }, { time: '7' }, { time: '8' }, { time: '9' }, { time: '10' }, { time: '11' }, { time: '12' }, { time: '13' }],
        nodeMatrix: [],
        selected: '',
        showDrawer: false,
        drawerContentHeight: '',
        deps: [],
        ruleValidate: {
          // cid,
          // cname,
          // credit,
          // dname
          cid: [
            { required: true, message: 'Course ID is required', trigger: 'blur' }
          ],
          cname: [
            { required: true, message: 'Course name is required', trigger: 'blur' }
          ],
          credit: [
            { required: true, type: 'integer', min: 1, message: 'Credits are required and must be numeric', trigger: 'change' }
          ],
          dname: [
            { required: true, message: 'Department is required', trigger: 'change' }
          ]
        },
        form: {
          cid: '',
          cname: '',
          credit: '',
          dname: ''
        },
        ruleValidate2: {
          // tid,
          // classTime
          tid: [
            { required: true, message: 'Teacher is required', trigger: 'blur' }
          ],
          classTime: [
            {
              required: true,
              validator(rule, value, callback) {
                if (!that.form2.tid) {
                  return callback(new Error('Please select a teacher first'))
                }
                that.$axios({
                  url: '/getTeacherCourseInfo',
                  method: 'post',
                  data: {
                    tid: that.form2.tid,
                    term: that.selected
                  }
                }).then((res) => {
                  const data = res.data
                  if (!data.cid) {
                    data.cid = []
                    data.classTime = []
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
                    //查看是否重复
                    let invalid = false
                    let cIndex = -1
                    iterateScheduleUnits(value, (i, j, index) => {
                      if (matrix[i][j]) {
                        invalid = true
                        cIndex = index
                        return true
                      }
                      return false
                    })
                    if (invalid) {
                      return callback(new Error(`This class time conflicts with ${data.cname[cIndex]} [${data.classTime[cIndex]}].`))
                    }
                  } catch (e) {
                    console.log(e)
                    return callback(e)
                  }
                  callback()
                }).catch((err) => {
                  callback(err)
                })
              }, trigger: 'blur'
            }
          ]
        },
        form2: {
          tid: '',
          classTime: ''
        },
        showModal: false,
        showModal2: false,
        modalLoading: true,
        modalLoading2: true
      }
    },
    methods: {
      async handleAddSchedule() {
        const that = this
        if (!await this.$refs.form2.validate()) {
          this.modalLoading2 = false
          this.$nextTick(() => {
            this.modalLoading2 = true
          })
          return
        }
        let {
          tid,
          classTime
        } = this.form2
        this.$axios({
          url: '/admin/courseManagement',
          method: 'post',
          data: {
            cid: this.thisRow.cid,
            tid,
            classTime,
            'op': 'addCourseSchedule'
          }
        }).then((res) => {
          if (res.data.message === 'ok') {
            this.$Message.info('Section added')
            this.showModal2 = false
            this.data2.push(Object.assign({
              cid: this.thisRow.cid,
              cname: this.thisRow.cname,
              credit: this.thisRow.credit,
              tname: this.allTname.find((_, index) => this.allTid[index] === this.form2.tid)
            }, this.form2))
            this.$refs.form2.resetFields()
            this.thisRow.count++
            this.$nextTick(() => {
              this.renderCalendar({ raw: [] })
            })
          } else {
            this.$Message.warning(res.data.message)
            this.modalLoading2 = false
            this.$nextTick(() => {
              that.modalLoading2 = true
            })
          }
        })
      },
      handleClickAddScheduleButton() {
        this.showModal2 = true
        this.$axios({
          url: '/getTidTname'
        }).then((res) => {
          this.allTid = res.data.tid
          this.allTname = res.data.tname
        })
      },
      async handleSwitchTerm() {
        this.data1 = []
        await this.$axios({
          url: `/admin/courseManagement`,
          method: 'post',
          data: {
            term: this.selected,
            op: 'select'
          }
        }).then((res) => {
          const { cid, cname, credit, dname, count } = res.data
          if (!cid) {
            return
          }
          for (let i = 0; i < cid.length; i++) {
            this.data1.push({
              cid: cid[i],
              cname: cname[i],
              credit: credit[i],
              dname: dname[i],
              count: count[i]
            })
          }
        })
      },
      async handleAddCourse() {
        const that = this
        if (!await this.$refs.form.validate()) {
          this.modalLoading = false
          this.$nextTick(() => {
            this.modalLoading = true
          })
          return
        }
        let {
          cid,
          cname,
          credit,
          dname
        } = this.form
        this.$axios({
          url: '/admin/courseManagement',
          method: 'post',
          data: {
            cid,
            cname,
            credit: credit.toString(),
            dname,
            'op': 'addCourse'
          }
        }).then((res) => {
          if (res.data.message === 'ok') {
            this.$Message.info('Course added')
            this.showModal = false
            this.data1.push(Object.assign({}, this.form, { count: 0 }))
            this.$refs.form.resetFields()
          } else {
            this.$Message.warning(res.data.message)
            this.modalLoading = false
            this.$nextTick(() => {
              that.modalLoading = true
            })
          }
        })
      },
      handleClickAddButton() {
        this.$refs.form.resetFields()
        this.showModal = true
        this.$axios({
          url: '/getDepartment'
        }).then((res) => {
          this.deps = res.data.dname
        })
      },
      initCalendarColor({ raw = this.data2 } = {}) {
        //计算，并赋予颜色
        let colorArrayBak = Object.assign([], colorArray)

        function swap(arr, i, j) {
          [arr[i], arr[j]] = [arr[j], arr[i]]
        }

        let cnt = 0
        raw.forEach((obj, index) => {
          if (!raw[index]._color) {
            swap(colorArrayBak, cnt, Math.floor(Math.random() * (colorArrayBak.length - cnt) + cnt))
            raw[index]._color = colorArrayBak[cnt++]
          }
        })
      },
      renderCalendar({
                       raw = this.data2,
                       hoverKh
                     } = {}) {
        //raw是课程数组
        //clear
        let matrix = new Array(13)
        if (this.nodeMatrix.length) {
          for (let i = 0; i < this.nodeMatrix.length; i++) {
            for (let j = 0; j < this.nodeMatrix[j].length; j++) {
              this.nodeMatrix[i][j].firstChild.innerHTML = ''
              this.nodeMatrix[i][j].style = ''
            }
          }
        }
        for (let i = 0; i < 13; i++) {
          matrix[i] = new Array(7)
        }
        //计算，并赋予颜色
        this.initCalendarColor()
        raw.forEach((obj, index) => {
          let x = Object.assign({}, obj)
          let ct = x.classTime.split(' ')
          //每个不同的时间段
          if (!ct) {
            ct = [x.classTime]
          }
          for (let j = 0; j < ct.length; j++) {
            const parsed = parseScheduleUnit(ct[j])
            const day = dayToColumnMap[parsed.day]
            const begin = parsed.start
            const end = parsed.end
            //给课程初始化一个颜色
            let color
            if (hoverKh === undefined || obj.cid === hoverKh) {//没有hover的元素，或hover的就是这个课程
              color = raw[index]._color
            } else {
              color = 'rgba(0,0,0,.2)'//灰色
            }
            matrix[begin - 1][day - 1] = {
              ...obj,
              color,
              _length: end - begin + 1
            }
          }
        })
        //开始渲染
        let tr = document.querySelectorAll('.calendar .ivu-table-tbody tr')
        for (let i = 0; i < tr.length; i++) {
          const tds = tr[i].querySelectorAll('td:not(:first-child)')
          this.nodeMatrix.push(tds)
        }
        const rawTbody = document.querySelector('.calendarRaw .ivu-table-tbody')
        rawTbody.onmouseleave = this.mouseLeaveTbody
        tr = rawTbody.querySelectorAll('tr')
        for (let i = 0; i < tr.length; i++) {
          tr[i].onmouseenter = () => (this.mouseEnterTr(i))
        }
        for (let i = 0; i < matrix.length; i++) {
          for (let j = 0; j < matrix[i].length; j++) {
            if (!matrix[i][j]) {
              continue
            }
            this.nodeMatrix[i][j].style.position = 'relative'
            this.nodeMatrix[i][j].firstChild.innerHTML = `
              <div class="node" style="
                height: ${matrix[i][j]._length}00%;
                background-color: ${matrix[i][j].color};
              ">
                <div>
                  <p style="font-weight:bold">${matrix[i][j].cname}</p>
                  <p style="font-weight:bold">${matrix[i][j].tname}</p>
                  <p style="font-weight:bold">${matrix[i][j].classTime}</p>
                </div>
              </div>
              `
            this.nodeMatrix[i][j].style.color = 'white'
          }
        }
      },
      mouseEnterTr(line) {
        this.renderCalendar({ raw: [this.$refs.calendarRaw.data[line]], hoverKh: this.$refs.calendarRaw.data[line].cid })
      },
      mouseLeaveTbody() {
        this.renderCalendar({ raw: [] })
      }
    },
    mounted() {
      that = this
      // this.renderCalendar({ raw: [] })
    }
  }
</script>

<style lang="scss">
  .courseManagementDrawer .ivu-drawer-body {
    padding: 0 !important;
  }
</style>
<style lang="scss" scoped>

</style>
