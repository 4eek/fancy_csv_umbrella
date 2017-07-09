import {Socket} from "phoenix"

const socket = new Socket("/socket")
const table = document.getElementById('jobs-table')

if (table) {
  jobsTable(socket, table).connect()
}

function jobsTable(socket, table) {
  const jobs = {}

  table.innerHTML = `
    <thead>
      <tr class="header">
        <th>Job ID</th>
        <th>File name</th>
        <th>Nº Success</th>
        <th>Nº Error</th>
        <th>Output</th>
      </tr>
    </thead>
    <tbody>
    </tbody>
  `

  function connect() {
    socket.connect()

    const channel = socket.channel('city_import:status')

    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("change", (job) => jobs[job.id] ? updateJob(job) : insertJob(job, 'afterbegin'))
    channel.on("jobs", (data) => data.jobs.forEach((job) => insertJob(job, 'beforeend')))
  }

  function updateJob(job) {
    const container = jobs[job.id]

    container.ok.innerHTML = job.ok
    container.error.innerHTML = job.error
    container.output.innerHTML = downloadLink(job)
  }

  function downloadLink(job) {
    return job.output ? `<a href="${job.output}">Download</a>` : '-'
  }

  function insertJob(job, position) {
    const container = document.createElement('tr')

    container.className = "job"
    container.innerHTML = `
      <td class="id">${job.id}</td>
      <td>${job.filename}</td>
      <td class="ok">${job.ok}</td>
      <td class="error">${job.error}</td>
      <td class="output">${downloadLink(job)}</td>
    `

    jobs[job.id] = {
      ok: container.querySelector('.ok'),
      error: container.querySelector('.error'),
      output: container.querySelector('.output')
    }

    table.querySelector('tbody').insertAdjacentElement(position, container)
  }

  return { connect: connect }
}
