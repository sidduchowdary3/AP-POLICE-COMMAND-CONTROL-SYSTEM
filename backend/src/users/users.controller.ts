import { Controller, Post, Get, Body, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { IsEmail, IsString, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  password: string;

  @IsOptional()
  @IsString()
  role?: string;

  @IsOptional()
  @IsString()
  stationId?: string;
}

@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post('stations')
  @Roles('SUPER_ADMIN')
  async createStation(@Body() body: { name: string, location: string }) {
    return this.usersService.createStation(body.name, body.location);
  }

  @Get('stations')
  @Roles('SUPER_ADMIN', 'COMMAND_OFFICER')
  async getStations() {
    return this.usersService.getStations();
  }

  @Post('users')
  @Roles('SUPER_ADMIN', 'COMMAND_OFFICER')
  async createUser(@Body() body: CreateUserDto, @Request() req: any) {
    // If Command Officer is creating, force role to PERSONNEL and lock to their station
    if (req.user.role === 'COMMAND_OFFICER') {
      body.role = 'PERSONNEL';
      body.stationId = req.user.stationId;
    }
    return this.usersService.createUser(body);
  }
}
