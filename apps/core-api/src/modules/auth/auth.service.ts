import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { TokenPair } from './auth.types';
import { Role } from '@prisma/client';

interface JwtPayload {
  sub: string;
  phone: string;
  role: Role;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });

    if (existing) {
      throw new ConflictException('Phone number already registered');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        phone: dto.phone,
        email: dto.email,
        passwordHash,
        role: dto.role,
        status: 'ACTIVE',
      },
    });

    return this.generateTokens({ sub: user.id, phone: user.phone, role: user.role });
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.status === 'SUSPENDED') {
      throw new UnauthorizedException('Account suspended');
    }

    return this.generateTokens({ sub: user.id, phone: user.phone, role: user.role });
  }

  async refresh(token: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!stored || stored.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (stored.user.status === 'SUSPENDED') {
      await this.prisma.refreshToken.delete({ where: { token } });
      throw new UnauthorizedException('Account suspended');
    }

    await this.prisma.refreshToken.delete({ where: { token } });

    return this.generateTokens({
      sub: stored.user.id,
      phone: stored.user.phone,
      role: stored.user.role,
    });
  }

  async logout(token: string) {
    await this.prisma.refreshToken.deleteMany({ where: { token } });
  }

  async getMe(userId: string) {
    return this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        id: true,
        phone: true,
        email: true,
        role: true,
        status: true,
        createdAt: true,
        clientProfile: true,
        merchantProfile: true,
        driverProfile: true,
      },
    });
  }

  private async generateTokens(payload: JwtPayload): Promise<TokenPair> {
    const accessSecret = this.config.getOrThrow<string>('JWT_ACCESS_SECRET');
    const refreshSecret = this.config.getOrThrow<string>('JWT_REFRESH_SECRET');
    const accessExpiresIn = this.config.get<string>('JWT_ACCESS_EXPIRES_IN', '15m');
    const refreshExpiresIn = this.config.get<string>('JWT_REFRESH_EXPIRES_IN', '30d');

    const [accessToken, refreshToken] = await Promise.all([
      this.jwt.signAsync(payload, {
        secret: accessSecret,
        expiresIn: accessExpiresIn as `${number}${'s'|'m'|'h'|'d'}`,
      }),
      this.jwt.signAsync(payload, {
        secret: refreshSecret,
        expiresIn: refreshExpiresIn as `${number}${'s'|'m'|'h'|'d'}`,
      }),
    ]);

    const refreshDays = parseInt(
      (refreshExpiresIn as string).replace(/\D/g, '') || '30',
      10,
    );
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + refreshDays);

    await this.prisma.refreshToken.create({
      data: {
        userId: payload.sub,
        token: refreshToken,
        expiresAt,
      },
    });

    return { accessToken, refreshToken };
  }
}
