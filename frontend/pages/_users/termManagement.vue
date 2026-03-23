<template>
  <div class="wrapper">
    <ButtonGroup class="operation">
      <Button type="primary" icon="md-add" size="large" @click="handleClickAddButton">
        Add Semester
      </Button>
      <Button type="warning" icon="md-close-circle" size="large" @click="handleClickOpenButton"
              v-if="openCourse">
        Close Registration
      </Button>
      <Button type="info" icon="md-checkmark-circle-outline" size="large" @click="handleClickOpenButton"
              v-else>
        Open Registration
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
      title="Add Semester"
      @on-ok="handleAddTerm"
      :loading="modalLoading"
      :mask-closable="false"
    >
      <Form
        :model="form"
        label-position="right"
        :rules="ruleValidate"
        :label-width="80"
        style="padding:20px 30px 20px 15px"
        ref="form"
      >
        <FormItem label="Semester" prop="term">
          <Input v-model="form.term"></Input>
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
  export default {
    name: 'term',
    async asyncData({ app }) {
      const data1 = []
      await app.$axios({
        url: '/admin/termManagement'
      }).then((res) => {
        const { isCurrent, term } = res.data
        if (!term) {
          return
        }
        for (let i = 0; i < term.length; i++) {
          data1.push({
            state: isCurrent[i] === 'yes' ? 'Current Semester' : '',
            isCurrent: isCurrent[i],
            term: term[i]
          })
        }
      })
      let openCourse = false
      await app.$axios({
        url: '/admin/courseManagement',
        method: 'post',
        data: { op: 'queryOpen' }
      }).then((res) => {
        openCourse = res.data.open === 'open'
      })
      return {
        data1,
        openCourse
      }
    },
    data() {
      const that = this
      return {
        modalLoading: true,
        deps: ['Computer Science'],
        columns: [{
          'title': 'Semester Name',
          'key': 'term',
          'align': 'center'
        }, {
          'title': 'Status',
          'key': 'state',
          'align': 'center'
        }, {
          'title': 'Actions',
          'key': 'action',
          'fixed': 'right',
          'width': 270,
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
                  type: params.row.isCurrent === 'yes' ? 'warning' : 'primary',
                  icon: 'md-create'
                },
                on: {
                  click: () => {
                    that.$Modal.confirm({
                      title: 'Confirm',
                      content: params.row.isCurrent === 'yes' ? `Are you sure you want to end semester ${params.row.term}?` : `Are you sure you want to set ${params.row.term} as the current semester?`,
                      loading: true,
                      onOk: () => {
                        // End semester
                        const op = params.row.isCurrent === 'yes' ? 'end' : 'set'
                        that.$axios({
                          url: '/admin/termManagement',
                          method: 'post',
                          data: {
                            op,
                            term: params.row.term
                          }
                        }).then((res) => {
                          that.$Modal.remove()
                          if (res.data.message === 'ok') {
                            that.$Message.info('Operation successful')
                            if (op === 'end') {
                              params.row.state = ''
                              params.row.isCurrent = 'no'
                            } else {
                              params.row.state = 'Current Semester'
                              params.row.isCurrent = 'yes'
                            }
                          } else {
                            that.$Message.warning(res.data.message)
                          }
                        })
                      },
                      onCancel: () => {
                      }
                    })
                  }
                }
              }, params.row.isCurrent === 'yes' ? 'End Current Semester' : 'Set as Current Semester'),
              h('Button', {
                props: {
                  type: 'error',
                  icon: 'md-trash',
                  disabled: params.row.isCurrent === 'yes'
                },
                on: {
                  click: () => {
                    that.$Modal.confirm({
                      title: 'Confirm',
                      content: `Are you sure you want to delete semester ${params.row.term}?`,
                      loading: true,
                      onOk: () => {
                        that.$axios({
                          url: '/admin/termManagement',
                          method: 'post',
                          data: {
                            term: params.row.term,
                            op: 'delete'
                          }
                        }).then((res) => {
                          that.$Modal.remove()
                          if (res.data.message === 'ok') {
                            that.$Message.info('Deleted successfully')
                            that.data1.splice(params.index, 1)
                          } else {
                            that.$Message.warning(res.data.message)
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
          term: ''
        },
        ruleValidate: {
          term: [
            { required: true, message: 'Semester name is required', trigger: 'blur' }
          ]
        },
        showModal: false,
        isAdding: false,
        thisRow: null,
        openCourse: false
      }
    },
    methods: {
      handleClickOpenButton() {
        if (this.openCourse) {
          this.$axios({
            url: '/admin/courseManagement',
            method: 'post',
            data: { op: 'close' }
          }).then((res) => {
            if (res.data.message === 'ok') {
              this.openCourse = false
              this.$Message.info('Operation successful')
            } else {
              this.$Message.warning(res.data.message)
            }
          })
        } else {
          this.$axios({
            url: '/admin/courseManagement',
            method: 'post',
            data: { op: 'open' }
          }).then((res) => {
            if (res.data.message === 'ok') {
              this.openCourse = true
              this.$Message.info('Operation successful')
            } else {
              this.$Message.warning(res.data.message)
            }
          })
        }

      },
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
      async handleAddTerm() {
        const that = this
        if (!await this.$refs.form.validate()) {
          this.modalLoading = false
          this.$nextTick(() => {
            this.modalLoading = true
          })
          return
        }
        let {
          term
        } = this.form
        this.$axios({
          url: '/admin/termManagement',
          method: 'post',
          data: {
            term,
            'op': 'add'
          }
        }).then((res) => {
          console.log('handleAddTerm', res.data)
          if (res.data.message === 'ok') {
            this.$Message.info('Added successfully')
            this.showModal = false
            this.data1.push(Object.assign({ state: '', isCurrent: 'no' }, this.form))
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
