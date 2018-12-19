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

import PluginPage from 'src/containers/PluginPage';
import PluginCard from 'src/components/PluginCard';

import { apiGet, apiPost } from 'src/util.js';

class Dashboard extends React.Component {
  state = {
    plugins: {},
    view: 'dashboard',
    currentPlugin: null,
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

  render() {
    switch(this.state.view) {
      case 'dashboard': return this.renderDashboard();
      case 'plugin': return <PluginPage onBack={e => this.setState({view: 'dashboard'})} plugin={this.state.currentPlugin}/>;
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Dashboard />,
    document.body.appendChild(document.createElement('div')),
  )
})
