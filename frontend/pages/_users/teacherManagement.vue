<template>
  <div class="wrapper">
    <ButtonGroup class="operation">
      <Button type="primary" icon="md-add" size="large" @click="handleClickAddButton">
        Add
      </Button>
    </ButtonGroup>
    <Table
      class="operation"
      stripe
      border
      :columns="columns"
      :data="data1"
    ></Table>
    <Modal
      v-model="showModal"
      :title="isAdding?'Add Teacher':'Edit Teacher'"
      @on-ok="handleAddTeacher"
      :loading="modalLoading"
      :mask-closable="false"
    >
      <!--
                tid: '',
                tname: '',
                gender: '',
                birthday: '',
                wage: '',
                education: '',
                dname: ''
      -->
      <Form
        :model="form"
        label-position="right"
        :rules="ruleValidate"
        :label-width="80"
        style="padding:20px 30px 20px 15px"
        ref="form"
      >
        <FormItem label="Employee ID" prop="tid">
          <Input v-model="form.tid" :disabled="!isAdding"></Input>
        </FormItem>
        <FormItem label="Name" prop="tname">
          <Input v-model="form.tname"></Input>
        </FormItem>
        <FormItem label="Department" prop="dname">
          <Select v-model="form.dname" placeholder="Select Department">
            <Option :value="dep" v-for="dep in deps" :key="dep">{{dep}}</Option>
          </Select>
        </FormItem>
        <FormItem label="Education" prop="education">
          <Select v-model="form.education" placeholder="Select Education">
            <Option value="Bachelor">Bachelor</Option>
            <Option value="Master">Master</Option>
            <Option value="PhD">PhD</Option>
          </Select>
        </FormItem>
        <FormItem label="Birthday" prop="birthday">
          <DatePicker type="date" placeholder="Select Date" v-model="form.birthday"></DatePicker>
        </FormItem>
        <FormItem label="Gender" prop="gender">
          <RadioGroup v-model="form.gender">
            <Radio label="Male">Male</Radio>
            <Radio label="Female">Female</Radio>
          </RadioGroup>
        </FormItem>
        <FormItem label="Salary" prop="wage">
          <Input v-model="form.wage" number></Input>
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
  export default {
    name: 'teacherManagement',
    async asyncData({ app }) {
      const data1 = []
      await app.$axios({
        url: '/admin/teacherManagement'
      }).then((res) => {
        const {
          tid,
          tname,
          gender,
          birthday,
          wage,
          education,
          dname
        } = res.data
        if (!tid) {
          return
        }
        for (let i = 0; i < tid.length; i++) {
          data1.push({
            tid: tid[i],
            gender: gender[i],
            birthday: birthday[i],
            tname: tname[i],
            wage: wage[i],
            education: education[i],
            dname: dname[i]
          })
        }
      })
      return {
        data1
      }
    },
    data() {
      const that = this
      return {
        modalLoading: true,
        deps: ['Computer Science'],
        columns: [{
          'title': 'Employee ID',
          'key': 'tid',
          'align': 'center',
          'sortable': true
        }, {
          'title': 'Name',
          'key': 'tname',
          'align': 'center'
        }, {
          'title': 'Gender',
          'key': 'gender',
          'align': 'center'
        }, {
          'title': 'Birthday',
          'key': 'birthday',
          'align': 'center'
        }, {
          'title': 'Education',
          'key': 'education',
          'align': 'center'
        }, {
          'title': 'Base Salary',
          'key': 'wage',
          'align': 'center'
        }, {
          'title': 'Department',
          'key': 'dname',
          'align': 'center',
          'sortable': true
        }, {
          'title': 'Actions',
          'key': 'action',
          'fixed': 'right',
          'width': 200,
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
                  icon: 'md-create'
                },
                on: {
                  click: () => {
                    that.thisRow = params.row
                    that.isAdding = false
                    that.form = Object.assign({}, params.row)
                    that.form.wage = parseInt(that.form.wage)
                    that.form.birthday = that.$dayjs(that.form.birthday, 'YYYYMMDD').toDate()
                    that.showModal = true
                    that.$axios({
                      url: '/getDepartment'
                    }).then((res) => {
                      that.deps = res.data.dname
                    })
                    console.log(that.form)
                  }
                }
              }, 'Edit'),
              h('Button', {
                props: {
                  type: 'warning',
                  icon: 'md-trash'
                },
                on: {
                  click: () => {
                    that.$Modal.confirm({
                      title: 'Confirm',
                      content: `Are you sure you want to delete teacher ${params.row.tname}?`,
                      loading: true,
                      onOk: () => {
                        that.$axios({
                          url: '/admin/teacherManagement',
                          method: 'post',
                          data: {
                            tid: params.row.tid,
                            op: 'delete'
                          }
                        }).then((res) => {
                          that.$Modal.remove()
                          if (res.data.message === 'ok') {
                            that.$Message.info('Deleted successfully')
                            that.data1.splice(params.index, 1)
                          } else {
                            that.$Notice.warning({
                              title: 'Notice',
                              desc: res.data.message
                            })
                          }
                        }).catch((err) => {
                          that.$Modal.remove()
                          that.$Notice.warning({
                            title: 'Notice',
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
        }],
        data1: [],
        form: {
          tid: '',
          tname: '',
          gender: '',
          birthday: '',
          wage: '',
          education: '',
          dname: ''
        },
        ruleValidate: {
          tid: [
            { required: true, message: 'Employee ID is required', trigger: 'blur' }
          ],
          tname: [
            { required: true, message: 'Name is required', trigger: 'blur' }
          ],
          birthday: [
            { required: true, type: 'date', message: 'Birthday is required and must be in a valid format', trigger: 'change' }
          ],
          gender: [
            { required: true, message: 'Gender is required', trigger: 'change' }
          ],
          wage: [
            { required: true, type: 'integer', min: 1, message: 'Salary is required and must be a positive number', trigger: 'change' }
          ],
          education: [
            { required: true, message: 'Education is required', trigger: 'change' }
          ],
          dname: [
            { required: true, message: 'Department is required', trigger: 'change' }
          ]
        },
        showModal: false,
        isAdding: false,
        thisRow: null
      }
    },
    methods: {
      handleClickAddButton() {
        if (!this.isAdding) {
          this.$refs.form.resetFields()
          this.isAdding = true
        }
        this.showModal = true
        this.$axios({
          url: '/getDepartment'
        }).then((res) => {
          this.deps = res.data.dname
        })
      },
      async handleAddTeacher() {
        const that = this
        if (!await this.$refs.form.validate()) {
          this.modalLoading = false
          this.$nextTick(() => {
            this.modalLoading = true
          })
          return
        }
        let {
          tid,
          tname,
          gender,
          birthday,
          wage,
          education,
          dname
        } = this.form
        birthday = this.$dayjs(birthday).format('YYYYMMDD')
        this.$axios({
          url: '/admin/teacherManagement',
          method: 'post',
          data: {
            tid,
            tname,
            gender,
            birthday,
            wage: wage.toString(),
            education,
            dname,
            'op': this.isAdding ? 'add' : 'modify'
          }
        }).then((res) => {
          console.log('handleAddTeacher', res.data)
          if (res.data.message === 'ok') {
            this.$Message.info(`${this.isAdding ? 'Added' : 'Updated'} successfully`)
            this.showModal = false
            this.form.birthday = birthday
            if (!this.isAdding) {
              for (let k in this.thisRow) {
                if (k in this.form) {
                  this.thisRow[k] = this.form[k]
                  console.log(k, this.form[k])
                }
              }
            } else {
              this.data1.push(Object.assign({}, this.form))
            }
            this.$refs.form.resetFields()
          } else {
            this.$Message.warning(res.data.message)
            this.modalLoading = false
            this.$nextTick(() => {
              that.modalLoading = true
            })
          }
        })
      }
    }
  }
</script>

<style scoped>

</style>
