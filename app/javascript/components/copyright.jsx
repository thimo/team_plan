import React from 'react'

class Copyright extends React.Component {
  render() {
    return (
      <div style={{float: 'right', padding: 30}}>Copyright &copy; {this.props.year}</div>
    )
  }
}

export default Copyright;
