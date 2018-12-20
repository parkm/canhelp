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
import ArrowBackIcon from '@material-ui/icons/ArrowBackIos';

import { apiGet, apiPost } from 'src/util.js';

export default class PluginPage extends React.Component {
  state = {
    submitting: false,
    statusText: '',
    statusTextColor: 'default'
  }

  componentWillMount() {
    this.pluginArgRefs = [];
  }

  onPluginSubmit(args) {
    let plugin = this.props.plugin;
    let pluginArgs = {};
    Object.entries(args).forEach((arg) => pluginArgs[arg[0]] = arg[1].value);

    this.setState({
      submitting: true,
      statusText: '',
      statusTextColor: 'default'
    });

    apiPost('plugins/execute', {
      plugin_file: plugin.fileName,
      plugin_method: plugin.method,
      plugin_args: pluginArgs
    }).then(r => {
      if (r.ok) {
        return r.json()
      } else {
        throw new Error(`(${r.status}) ${r.statusText}`);
      }
    }).then(data => {
      this.setState({
        submitting: false,
        statusText: 'Completed!'
      });
    }).catch(err => {
      this.setState({
        submitting: false,
        statusText: err.message,
        statusTextColor: 'error'
      });
    });
  }

  render() {
    let plugin = this.props.plugin;
    return (
      <div>
        <Button onClick={this.props.onBack}><ArrowBackIcon/> Back to Dashboard</Button>
        <Typography align="center" variant="h4">{plugin.name}</Typography>
        <Card>
          <CardContent>
            <Grid container spacing={24} sm={12}>
              {plugin.args.map(arg => {
                return (
                  <Grid item sm={3}>
                    <TextField fullWidth label={arg} inputRef={r => this.pluginArgRefs[arg] = r} />
                  </Grid>
                );
              })}
            </Grid>
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
            <Typography color={this.state.statusTextColor}>{this.state.statusText}</Typography>
          </CardActions>
        </Card>
      </div>
    );
  }
}
