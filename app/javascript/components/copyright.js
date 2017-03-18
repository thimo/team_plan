import React from 'react'
// import ReactDOM from 'react-dom'

class Copyright extends React.Component {
  render() {
    return <div style={{float: 'right', padding: 30}}>Copyright &copy; {this.props.year}</div>
  }
}

// document.addEventListener("DOMContentLoaded", e => {
//   ReactDOM.render(<Hello year={(new Date).getFullYear()} />, document.body.appendChild(document.createElement('div')))
// })

export default Copyright;

// import React from 'react';
//
// class Hello extends React.Component {
//   render() {
//     return <div>
//              Hello, I am {this.props.name}!
//            </div>
//   }
// }
//
// export default Hello;
