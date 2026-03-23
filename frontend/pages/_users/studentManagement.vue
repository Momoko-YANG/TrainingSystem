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
      :title="isAdding?'Add Student':'Edit Student'"
      @on-ok="handleAddStudent"
      :loading="modalLoading"
      :mask-closable="false"
    >
      <!--
          id,
          name,
          gender,
          birthday,
          birthplace,
          phone
          dname,
          grade,
      -->
      <Form
        :model="form"
        label-position="right"
        :rules="ruleValidate"
        :label-width="80"
        style="padding:20px 30px 20px 15px"
        ref="form"
      >
        <FormItem label="Student ID" prop="id" :disabled="!isAdding">
          <Input v-model="form.id"></Input>
        </FormItem>
        <FormItem label="Name" prop="name">
          <Input v-model="form.name"></Input>
        </FormItem>
        <FormItem label="Department" prop="dname">
          <Select v-model="form.dname" placeholder="Select Department">
            <Option :value="dep" v-for="dep in deps" :key="dep">{{dep}}</Option>
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
        <FormItem label="Birthplace" prop="birthplace">
          <Input v-model="form.birthplace"></Input>
        </FormItem>
        <FormItem label="Phone" prop="phone">
          <Input v-model="form.phone" number></Input>
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
  export default {
    name: 'studentManagement',
    async asyncData({ app }) {
      const data1 = []
      await app.$axios({
        url: '/admin/studentManagement'
      }).then((res) => {
        const {
          birthday,
          birthplace,
          did,
          dname,
          gender,
          id,
          name,
          phone
        } = res.data
        if (!id) {
          return
        }
        for (let i = 0; i < id.length; i++) {
          data1.push({
            birthday: birthday[i],
            birthplace: birthplace[i],
            did: did[i],
            dname: dname[i],
            gender: gender[i],
            id: id[i],
            name: name[i],
            phone: phone[i]
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
        ruleValidate: {
          // id,
          // name,
          // gender,
          // birthday,
          // birthplace,
          // phone,
          // dname
          id: [
            { required: true, message: 'Student ID is required', trigger: 'blur' }
          ],
          name: [
            { required: true, message: 'Name is required', trigger: 'blur' }
          ],
          birthday: [
            { required: true, type: 'date', message: 'Birthday is required and must be in a valid format', trigger: 'change' }
          ],
          gender: [
            { required: true, message: 'Gender is required', trigger: 'change' }
          ],
          phone: [
            { required: true, type: 'integer', min: 1, message: 'Phone is required and must be a number', trigger: 'change' }
          ],
          birthplace: [
            { required: true, message: 'Birthplace is required', trigger: 'change' }
          ],
          dname: [
            { required: true, message: 'Department is required', trigger: 'change' }
          ]
        },
        form: {
          birthday: '',
          birthplace: '',
          did: '',
          dname: '',
          gender: '',
          grade: '',
          id: '',
          name: '',
          phone: ''
        },
        showModal: false,
        columns: [{
          'title': 'Student ID',
          'key': 'id',
          'align': 'center',
          'sortable': true
        }, {
          'title': 'Name',
          'key': 'name',
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
          'title': 'Birthplace',
          'key': 'birthplace',
          'align': 'center'
        }, {
          'title': 'Phone',
          'key': 'phone',
          'align': 'center'
        }, {
          'title': 'Department',
          'key': 'dname',
          'align': 'center'
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
                    that.form.phone = parseInt(that.form.phone)
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
                      content: `Are you sure you want to delete student ${params.row.name}?`,
                      loading: true,
                      onOk: () => {
                        that.$axios({
                          url: '/admin/studentManagement',
                          method: 'post',
                          data: {
                            id: params.row.id,
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
      async handleAddStudent() {
        const that = this
        if (!await this.$refs.form.validate()) {
          this.modalLoading = false
          this.$nextTick(() => {
            this.modalLoading = true
          })
          return
        }
        let {
          id,
          name,
          gender,
          birthday,
          birthplace,
          phone,
          dname
        } = this.form
        birthday = this.$dayjs(birthday).format('YYYYMMDD')
        this.$axios({
          url: '/admin/studentManagement',
          method: 'post',
          data: {
            id,
            name,
            gender,
            birthday,
            birthplace,
            phone: phone.toString(),
            dname,
            'op': this.isAdding ? 'add' : 'modify'
          }
        }).then((res) => {
          if (res.data.message === 'ok') {
            this.$Message.info(`${this.isAdding ? 'Added' : 'Updated'} successfully`)
            this.showModal = false
            this.form.birthday = birthday
            if (!this.isAdding) {
              for (let k in this.thisRow) {
                if (k in this.form) {
                  this.thisRow[k] = this.form[k]
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
