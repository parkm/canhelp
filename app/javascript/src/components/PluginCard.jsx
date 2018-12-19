import React from 'react'

import Button from '@material-ui/core/Button';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';

export default class PluginCard extends React.Component {
  render() {
    return (
      <Card
      >
        <CardHeader title={this.props.title} subheader={this.props.description}/>
        <CardActions>
          <Button color="primary" onClick={this.props.onClick}>{this.props.title}</Button>
        </CardActions>
      </Card>
    );
  }
}
