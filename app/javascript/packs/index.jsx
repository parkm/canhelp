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
            <Button variant="primary">{this.props.title}</Button>
          </View>
        </div>
      </View>
    );
  }
}

class Dashboard extends React.Component {
  render() {
    return (
      <div id="dashboard">
        <Heading level="h1" align="center">CanHelp Dashboard</Heading>
        <Flex>
          <FlexItem>
            <PluginCard title="Create Courses" description="Create one or more Canvas Courses."/>
          </FlexItem>
          <FlexItem>
            <PluginCard title="Create Assignments" description="Create one or more Canvas Assignments."/>
          </FlexItem>
          <FlexItem>
            <PluginCard title="Create Users" description="Create users and enroll them in a course."/>
          </FlexItem>
        </Flex>
      </div>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Dashboard />,
    document.body.appendChild(document.createElement('div')),
  )
})
