//heavily modified from ruby/audio/directsound.cpp (original author: byuu)

#include <stdint.h>

void audio_init(double sample_rate);
void audio_sample(int16_t left, int16_t right);
void audio_clear();
void audio_term();

#if 1
#include <dsound.h>

const GUID GUID_NULL = { 0, 0, 0, { 0, 0, 0, 0, 0, 0, 0, 0 } };

static LPDIRECTSOUND ds;
static LPDIRECTSOUNDBUFFER dsb_p, dsb_b;
static DSBUFFERDESC dsbd;
static WAVEFORMATEX wfx;

static double samplerate;

//static HWND handle;

struct {
	unsigned rings;
	unsigned latency;

	uint32_t *buffer;
	unsigned bufferoffset;

	unsigned readring;
	unsigned writering;
	int distance;
} static device;

void audio_sample(int16_t left, int16_t right) {
	device.buffer[device.bufferoffset++] = left + (right << 16);
	if(device.bufferoffset < device.latency) return;
	device.bufferoffset = 0;

	DWORD pos, size;
	void *output;

	if (1) {
	//if(settings.synchronize == true) {
		//wait until playback buffer has an empty ring to write new audio data to
		while(device.distance >= (int)device.rings - 1) {
			HRESULT err=dsb_b->GetCurrentPosition(0, &pos);
			if (err)
			{
				if (err==DSERR_BUFFERLOST)//workaround if something (*coughzsnescough*) pulls the primary sound buffer
				{
					audio_term();
					audio_init(samplerate);
				}
				if (err==DSERR_OTHERAPPHASPRIO)//in case zsomething is still running; it'll throw FPS exactly everywhere, but whatever. it's better than crashing
				{
					static bool warned=false;
					if (!warned)
					{
						MessageBox(NULL, "Something is demanding exclusive rights of the sound on this machine. "
															"LMSW needs sound synchronization to keep the FPS sane. Please disable this other program, "
															"or LMSW's speed will only be limited by your CPU speed.", "LMSW", MB_OK|MB_ICONSTOP);
						warned=true;
					}
				}
				return;
			}
			unsigned activering = pos / (device.latency * 4);
			if(activering == device.readring) {
				//if(settings.synchronize == false) Sleep(1);
				Sleep(10);
				continue;
			}

			//subtract number of played rings from ring distance counter
			device.distance -= (device.rings + activering - device.readring) % device.rings;
			device.readring = activering;

			if(device.distance < 2) {
				//buffer underflow; set max distance to recover quickly
				device.distance  = device.rings - 1;
				device.writering = (device.rings + device.readring - 1) % device.rings;
				break;
			}
		}
	}

	device.writering = (device.writering + 1) % device.rings;
	device.distance  = (device.distance  + 1) % device.rings;

	if(dsb_b->Lock(device.writering * device.latency * 4, device.latency * 4, &output, &size, 0, 0, 0) == DS_OK) {
		memcpy(output, device.buffer, device.latency * 4);
		dsb_b->Unlock(output, size, 0, 0);
	}
}

void audio_clear() {
	device.readring  = 0;
	device.writering = device.rings - 1;
	device.distance  = device.rings - 1;

	device.bufferoffset = 0;
	if(device.buffer) memset(device.buffer, 0, device.latency * device.rings * 4);

	if(!dsb_b) return;
	dsb_b->Stop();
	dsb_b->SetCurrentPosition(0);

	DWORD size;
	void *output;
	dsb_b->Lock(0, device.latency * device.rings * 4, &output, &size, 0, 0, 0);
	memset(output, 0, size);
	dsb_b->Unlock(output, size, 0, 0);

	dsb_b->Play(0, 0, DSBPLAY_LOOPING);
}

void audio_init(double sample_rate) {
	samplerate=sample_rate;
	ds = 0;
	dsb_p = 0;
	dsb_b = 0;

	device.buffer = 0;
	device.bufferoffset = 0;
	device.readring = 0;
	device.writering = 0;
	device.distance = 0;

	device.rings   = 8;
	device.latency = samplerate * 60 / device.rings / 1000.0 + 0.5;
	device.buffer  = new uint32_t[device.latency * device.rings];
	device.bufferoffset = 0;

	DirectSoundCreate(0, &ds, 0);
	ds->SetCooperativeLevel(GetDesktopWindow(), DSSCL_PRIORITY);

	memset(&dsbd, 0, sizeof(dsbd));
	dsbd.dwSize        = sizeof(dsbd);
	dsbd.dwFlags       = DSBCAPS_PRIMARYBUFFER;
	dsbd.dwBufferBytes = 0;
	dsbd.lpwfxFormat   = 0;
	ds->CreateSoundBuffer(&dsbd, &dsb_p, 0);

	memset(&wfx, 0, sizeof(wfx));
	wfx.wFormatTag      = WAVE_FORMAT_PCM;
	wfx.nChannels       = 2;
	wfx.nSamplesPerSec  = samplerate;
	wfx.wBitsPerSample  = 16;
	wfx.nBlockAlign     = wfx.wBitsPerSample / 8 * wfx.nChannels;
	wfx.nAvgBytesPerSec = wfx.nSamplesPerSec * wfx.nBlockAlign;
	dsb_p->SetFormat(&wfx);

	memset(&dsbd, 0, sizeof(dsbd));
	dsbd.dwSize  = sizeof(dsbd);
	dsbd.dwFlags = DSBCAPS_GETCURRENTPOSITION2 | DSBCAPS_CTRLFREQUENCY | DSBCAPS_GLOBALFOCUS | DSBCAPS_LOCSOFTWARE;
	dsbd.dwBufferBytes   = device.latency * device.rings * sizeof(uint32_t);
	dsbd.guid3DAlgorithm = GUID_NULL;
	dsbd.lpwfxFormat     = &wfx;
	ds->CreateSoundBuffer(&dsbd, &dsb_b, 0);
	dsb_b->SetFrequency(samplerate);
	dsb_b->SetCurrentPosition(0);

	audio_clear();
}

void audio_term() {
	if(device.buffer) {
		delete[] device.buffer;
		device.buffer = 0;
	}

	if(dsb_b) { dsb_b->Stop(); dsb_b->Release(); dsb_b = 0; }
	if(dsb_p) { dsb_p->Stop(); dsb_p->Release(); dsb_p = 0; }
	if(ds) { ds->Release(); ds = 0; }
}

#else
void audio_sample(int16_t left, int16_t right)
{
}

void audio_clear()
{
}

void audio_init(double sample_rate)
{
}

void audio_term()
{
}
#endif
