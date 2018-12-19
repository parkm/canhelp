import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

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

let apiGet = (url) => {
  let csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  return fetch('/api/internal/'+url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    credentials: 'include'
  }).then(r => r.json());
}

let apiPost = (url, body) => {
  let csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  return fetch('/api/internal/'+url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify(body),
    credentials: 'include'
  }).then(r => r.json());
}

class PluginCard extends React.Component {
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

class Dashboard extends React.Component {
  state = {
    plugins: {},
    view: 'dashboard',
    currentPlugin: null,
    submitting: false,
    fetchingPlugins: true
  }

  componentWillMount() {
    apiGet('plugins').then(data => {
      this.setState({
        plugins: data.plugins,
        fetchingPlugins: false
      });
    });
  }

  onPluginCardClick(pluginFileName, plugin) {
    plugin.fileName = pluginFileName;
    this.setState({
      view: 'plugin',
      currentPlugin: plugin,
    });
    this.pluginArgRefs = [];
  }

  renderDashboard() {
    return (
      <div >
        <Typography align="center" variant="h3" gutterBottom>CanHelp Dashboard</Typography>
        {this.state.fetchingPlugins ? (
          <Typography align="center">
            <Typography variant="h5" gutterBottom>
              Fetching Plugins...
            </Typography>
            <CircularProgress size={80}/>
          </Typography>
        ) : (
          <Grid container spacing={24}>
            {Object.entries(this.state.plugins).map(plugin => {
              return (
                <Grid item>
                  <PluginCard
                    title={plugin[1].name}
                    description={plugin[1].description}
                    onClick={e => this.onPluginCardClick(plugin[0], plugin[1])}
                  />
                </Grid>
              );
            })}
          </Grid>
        )}
      </div>
    );
  }

  renderPlugin() {
    let plugin = this.state.currentPlugin;
    return (
      <div>
        <Button onClick={_ => this.setState({view: 'dashboard'})}>Back to Dashboard</Button>
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
          </CardActions>
        </Card>
      </div>
    );
  }

  onPluginSubmit(args) {
    let plugin = this.state.currentPlugin;
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
