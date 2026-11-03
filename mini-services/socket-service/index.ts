import { createServer } from 'http';
import { Server } from 'socket.io';

const httpServer = createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('RapidAid Socket Service Running');
});

const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

const rooms = new Map<string, Set<string>>();

io.on('connection', (socket) => {
  console.log(`[Socket] Connected: ${socket.id}`);

  socket. on('join-incident', (incidentId: string) => {
    socket.join(`incident:${incidentId}`);
    if (!rooms.has(incidentId)) rooms.set(incidentId, new Set());
    rooms.get(incidentId)!.add(socket.id);
    console.log(`[Socket] ${socket.id} joined incident:${incidentId}`);
  });

  socket.on('leave-incident', (incidentId: string) => {
    socket.leave(`incident:${incidentId}`);
    rooms.get(incidentId)?.delete(socket.id);
  });

  socket.on('send-message', (data: { incidentId: string; message: any }) => {
    io.to(`incident:${data.incidentId}`).emit('new-message', data.message);
  });

  socket.on('sos-activated', (data: { incident: any }) => {
    io.emit('sos-new', data.incident);
    io.emit('notification', {
      title: 'New SOS Alert',
      message: `Emergency ${data.incident.incidentId} reported`,
      type: 'SOS',
    });
  });

  socket.on('sos-updated', (data: { incidentId: string; status: string }) => {
    io.to(`incident:${data.incidentId}`).emit('sos-status-changed', data);
    io.emit('sos-list-updated', data);
    io.emit('notification', {
      title: 'Status Update',
      message: `Emergency ${data.incidentId} → ${data.status}`,
      type: 'STATUS',
    });
  });

  socket.on('location-update', (data: { incidentId: string; latitude: number; longitude: number }) => {
    io.to(`incident:${data.incidentId}`).emit('location-changed', data);
  });

  socket.on('disaster-alert', (data: { alert: any }) => {
    io.emit('new-disaster-alert', data.alert);
  });

  socket.on('rescue-assigned', (data: { incidentId: string; team: any }) => {
    io.to(`incident:${data.incidentId}`).emit('rescue-team-assigned', data);
    io.emit('sos-list-updated', { incidentId: data.incidentId, status: 'ASSIGNED' });
  });

  socket.on('disconnect', () => {
    console.log(`[Socket] Disconnected: ${socket.id}`);
    for (const [id, set] of rooms) {
      set.delete(socket.id);
      if (set.size === 0) rooms.delete(id);
    }
  });
});

const PORT = 3003;
httpServer.listen(PORT, () => {
  console.log(`[Socket] RapidAid Socket Service running on port ${PORT}`);
});
