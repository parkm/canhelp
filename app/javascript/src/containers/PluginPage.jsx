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
import Switch from '@material-ui/core/Switch';
import FormControlLabel from '@material-ui/core/FormControlLabel';

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
    Object.entries(args).forEach((arg) => pluginArgs[arg[0]] = (arg[1].checked || arg[1].value).toString());

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

  renderArgType(type, argName) {
    let inputRef = (ref) => this.pluginArgRefs[argName] = ref;
    switch(type) {
      case 'bool':
        return (
          <FormControlLabel
            control={
              <Switch
                value={false}
              />
            }
            label={argName}
            inputRef={inputRef}
          />
        );
      case 'int':
        return <TextField fullWidth type="number" label={argName} inputRef={inputRef} />
      case 'date':
        return <TextField fullWidth defaultValue={(new Date()).toISOString()} label={argName} inputRef={inputRef} />
      default:
        return <TextField fullWidth label={argName} inputRef={inputRef} />
    }
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
                let argName = arg;
                let argType = 'text';
                if (Array.isArray(arg)) {
                  argName = arg[0];
                  argType = arg[1];
                }
                return (
                  <Grid item sm={3}>
                    {this.renderArgType(argType, argName)}
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
