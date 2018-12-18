import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import theme from '@instructure/ui-themes/lib/canvas'
theme.use();

import Heading from '@instructure/ui-elements/lib/components/Heading'
import View from '@instructure/ui-layout/lib/components/View'
import Modal from '@instructure/ui-overlays/lib/components/Modal'
import ModalHeader from '@instructure/ui-overlays/lib/components/Modal'
import ModalBody from '@instructure/ui-overlays/lib/components/Modal'
import ModalFooter from '@instructure/ui-overlays/lib/components/Modal'
import Text from '@instructure/ui-elements/lib/components/Text'
import Button from '@instructure/ui-buttons/lib/components/Button'
import Grid from '@instructure/ui-layout/lib/components/Grid'
import GridCol from '@instructure/ui-layout/lib/components/Grid'
import GridRow from '@instructure/ui-layout/lib/components/Grid'
import Flex from '@instructure/ui-layout/lib/components/Flex'
import FlexItem from '@instructure/ui-layout/lib/components/Flex'
import Link from '@instructure/ui-elements/lib/components/Link'
import TextInput from '@instructure/ui-forms/lib/components/TextInput'

class PluginCard extends React.Component {
  render() {
    return (
      <View
        as="div"
        margin="small"
        padding="large"
        textAlign="left"
        background="default"
        shadow="topmost"
      >
        <div style={{"padding-bottom": "24px"}}>
          <Heading level="h2">{this.props.title}</Heading>
          <Text color="secondary">{this.props.description}</Text>
        </div>
        <div>
          <View
            as="div"
            textAlign="left"
            background="default"
          >
            <Button variant="primary" onClick={this.props.onClick}>{this.props.title}</Button>
          </View>
        </div>
      </View>
    );
  }
}

class Dashboard extends React.Component {
  state = {
    plugins: {
      "create_users.rb": {
        name: 'Create Users',
        description: 'Create users and enroll them in a course.',
        args: ['course_id']
      }
    },
    view: 'dashboard',
    currentPlugin: null,
  }

  onPluginCardClick(plugin) {
    this.setState({
      view: 'plugin',
      currentPlugin: plugin,
    });
    this.pluginArgRefs = [];
  }

  renderDashboard() {
    return (
      <div >
        <Heading level="h1" align="center">CanHelp Dashboard</Heading>
        <Flex>
          {Object.values(this.state.plugins).map(plugin => {
            return (
              <FlexItem>
                <PluginCard
                  title={plugin.name}
                  description={plugin.description}
                  onClick={e => this.onPluginCardClick(plugin)}
                />
              </FlexItem>
            );
          })}
          <FlexItem>
            <PluginCard title="Create Courses" description="Create one or more Canvas Courses."/>
          </FlexItem>
          <FlexItem>
            <PluginCard title="Create Assignments" description="Create one or more Canvas Assignments."/>
          </FlexItem>
        </Flex>
      </div>
    );
  }

  renderPlugin() {
    let plugin = this.state.currentPlugin;
    return (
      <div>
        <Link onClick={_ => this.setState({view: 'dashboard'})}>Back to Dashboard</Link>
        <Heading level="h1" align="center">{plugin.name}</Heading>
        <View
          as="div"
          margin="small"
          padding="large"
          textAlign="left"
          background="default"
          shadow="topmost"
        >
          {plugin.args.map(arg => {
            return (
              <TextInput label={arg} ref={r => this.pluginArgRefs[arg] = r} />
            );
          })}
          <div style={{"margin-top": "24px"}}>
            <Button
              variant="primary"
              onClick={e => this.onPluginSubmit(this.pluginArgRefs) }
            >
              Submit
            </Button>
          </div>
        </View>
      </div>
    );
  }

  onPluginSubmit(args) {
    let plugin = this.state.currentPlugin;
    Object.entries(args).forEach((arg) => {
      console.log(`${arg[0]} = ${arg[1].value}`)
    });
  }

  render() {
    switch(this.state.view) {
      case 'dashboard': return this.renderDashboard();
      case 'plugin': return this.renderPlugin();
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Dashboard />,
    document.body.appendChild(document.createElement('div')),
  )
})
