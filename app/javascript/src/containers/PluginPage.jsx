import React from 'react'
import Button from '@material-ui/core/Button';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import CircularProgress from '@material-ui/core/CircularProgress';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';

import SendIcon from '@material-ui/icons/Send';

import { apiGet, apiPost } from 'src/util.js';

export default class PluginPage extends React.Component {
  state = {
    submitting: false
  }

  componentWillMount() {
    this.pluginArgRefs = [];
  }

  onPluginSubmit(args) {
    let plugin = this.props.plugin;
    let pluginArgs = {};
    Object.entries(args).forEach((arg) => pluginArgs[arg[0]] = arg[1].value);

    this.setState({submitting: true});

    apiPost('plugins/execute', {
      plugin_file: plugin.fileName,
      plugin_method: plugin.method,
      plugin_args: pluginArgs
    }).then(data => {
      this.setState({submitting: false});
    });
  }

  render() {
    let plugin = this.props.plugin;
    return (
      <div>
        <Button onClick={this.props.onBack}>Back to Dashboard</Button>
        <Typography align="center" variant="h4">{plugin.name}</Typography>
        <Card
        >
          <CardContent>
            {plugin.args.map(arg => {
              return (
                <TextField label={arg} ref={r => this.pluginArgRefs[arg] = r} />
              );
            })}
          </CardContent>
          <CardActions>
            <Button
              variant="contained"
              color="primary"
              onClick={e => this.onPluginSubmit(this.pluginArgRefs) }
              disabled={this.state.submitting}
            >
              Submit <SendIcon/>
            </Button>
            {this.state.submitting ? <CircularProgress/> : null}
          </CardActions>
        </Card>
      </div>
    );
  }
}
