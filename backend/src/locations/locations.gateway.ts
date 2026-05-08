import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class LocationsGateway implements OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit {
  @WebSocketServer()
  server: Server;

  private simulatorInterval: NodeJS.Timeout;
  
  // Andhra Pradesh District Patrol Units
  private units = [
    { id: 'VSP-1A', officer: 'Ravi Kumar, K.', lat: 17.6868, lng: 83.2185, status: 'BUSY' },         // Visakhapatnam
    { id: 'VJA-2B', officer: 'Suresh, P.',     lat: 16.5062, lng: 80.6480, status: 'AVAILABLE' },      // Vijayawada
    { id: 'TPT-3C', officer: 'Naidu, S.',       lat: 13.6288, lng: 79.4192, status: 'EN ROUTE' },      // Tirupati
    { id: 'GNT-4D', officer: 'Rao, M.',         lat: 16.3067, lng: 80.4365, status: 'AVAILABLE' },     // Guntur
    { id: 'KNL-5E', officer: 'Reddy, V.',       lat: 15.8281, lng: 78.0373, status: 'BUSY' },          // Kurnool
    { id: 'NLR-6F', officer: 'Prasad, A.',      lat: 14.4426, lng: 79.9865, status: 'EN ROUTE' },      // Nellore
    { id: 'KKD-7G', officer: 'Varma, B.',       lat: 16.9891, lng: 82.2475, status: 'AVAILABLE' },     // Kakinada
    { id: 'RJY-8H', officer: 'Sharma, C.',      lat: 17.0005, lng: 81.8040, status: 'EN ROUTE' },      // Rajahmundry
  ];

  afterInit() {
    console.log('WebSocket Gateway Initialized. Starting AP Police Simulator...');
    this.startSimulator();
  }

  handleConnection(client: Socket) {
    console.log(`Frontend Connected: ${client.id}`);
    client.emit('syncUnits', this.units);
  }

  handleDisconnect(client: Socket) {
    console.log(`Frontend Disconnected: ${client.id}`);
  }

  @SubscribeMessage('triggerBackup')
  handleBackupRequest(
    @MessageBody() data: { unitId: string; lat?: number; lng?: number },
    @ConnectedSocket() client: Socket,
  ) {
    console.log(`EMERGENCY: Backup requested by ${data.unitId}`);
    
    const newAlert = {
      type: 'OFFICER NEEDS BACKUP',
      unitId: data.unitId,
      unit: data.unitId,
      message: `BACKUP REQUESTED by Unit ${data.unitId}`,
      location: data.lat ? `Lat: ${data.lat.toFixed(4)}, Lng: ${data.lng?.toFixed(4)}` : 'GPS Coordinates Transmitted',
      lat: data.lat ?? 15.9129,
      lng: data.lng ?? 79.7400,
      time: 'Just now',
      isCritical: true,
    };
    
    this.server.emit('newAlert', newAlert);
    return { status: 'acknowledged' };
  }

  // AP-relevant incident types
  private readonly AP_INCIDENTS = [
    'SUSPICIOUS VEHICLE',
    'LAW & ORDER SITUATION',
    'TRAFFIC ACCIDENT',
    'CHAIN SNATCHING',
    'LIQUOR VIOLATION',
    'DOMESTIC DISPUTE',
    'MISSING PERSON REPORT',
    'SAND MAFIA ACTIVITY',
    'PROPERTY THEFT',
    'HIGH SPEED PURSUIT',
  ];

  private startSimulator() {
    this.simulatorInterval = setInterval(() => {
      // Slightly move units to simulate driving within AP
      this.units = this.units.map(unit => {
        const latChange = (Math.random() - 0.5) * 0.002;
        const lngChange = (Math.random() - 0.5) * 0.002;
        return {
          ...unit,
          lat: unit.lat + latChange,
          lng: unit.lng + lngChange,
        };
      });

      this.server.emit('syncUnits', this.units);

      // Randomly trigger an AP-relevant alert
      if (Math.random() > 0.8) {
        const selectedUnit = this.units[Math.floor(Math.random() * this.units.length)];
        const incidentType = this.AP_INCIDENTS[Math.floor(Math.random() * this.AP_INCIDENTS.length)];
        const isCritical = Math.random() > 0.7;
        const newAlert = {
          type: incidentType,
          unitId: selectedUnit.id,
          unit: selectedUnit.id,
          message: `${incidentType} — Unit ${selectedUnit.id} responding`,
          location: `Lat: ${selectedUnit.lat.toFixed(4)}, Lng: ${selectedUnit.lng.toFixed(4)}`,
          lat: selectedUnit.lat,
          lng: selectedUnit.lng,
          time: 'Just now',
          isCritical,
        };
        this.server.emit('newAlert', newAlert);
      }

    }, 3000);
  }
}
