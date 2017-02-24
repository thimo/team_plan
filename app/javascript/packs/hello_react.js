// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'

class Hello extends React.Component {
  render() {
    return <div style={{float: 'right', padding: 30}}>Copyright &copy; {this.props.year}</div>
  }
}

document.addEventListener("DOMContentLoaded", e => {
  ReactDOM.render(<Hello year={(new Date).getFullYear()} />, document.body.appendChild(document.createElement('div')))
})
