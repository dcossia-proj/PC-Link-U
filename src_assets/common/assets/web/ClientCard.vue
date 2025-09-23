<template>
    <div class="card p-2">
        <div class="card-body">
            <h2>{{ $t('client_card.clients') }}</h2>
            <br>
            <p>{{ $t('client_card.clients_desc') }}</p>
            <div class="card-group p-4 align-items-center">
                <a v-for="{ platform, icon, name, link } of clients" class="btn m-1" :class="getButtonClass(platform, link)" :href="link" target="_blank" @click="shouldOpen($event, link)"><i v-if="icon" :class="icon"></i> <span class="platform-text">{{ platform }}</span> [ {{ name }} ] </a>
            </div>
            <i>* {{ $t('client_card.generic_moonlight_clients_desc') }}</i>
        </div>
    </div>
</template>

<style scoped>
    .platform-text {
        font-weight: bold;
    }

    .btn-purple {
        background-color: #8b5cf6;
        border-color: #8b5cf6;
        color: white;
    }

    .btn-purple:hover {
        background-color: #7c3aed;
        border-color: #7c3aed;
        color: white;
    }

    .btn-purple:focus {
        background-color: #7c3aed;
        border-color: #7c3aed;
        color: white;
        box-shadow: 0 0 0 0.25rem rgba(139, 92, 246, 0.25);
    }
</style>

<script setup>
    const clients = [
        {
            platform: 'Android',
            icon: 'fa-brands fa-android',
            name: 'Artemis',
            link: 'https://github.com/ClassicOldSong/moonlight-android'
        },
        {
            platform: 'iOS',
            icon: 'fa-brands fa-apple',
            name: 'Void Link (unofficial)',
            link: 'https://apps.apple.com/us/app/voidlink/id6747717070'
        },
        {
            platform: 'Desktop',
            icon: 'fa-solid fa-desktop',
            name: 'Artemis-qt (WIP/alpha)',
            link: 'https://github.com/wjbeckett/artemis/tree/develop'
        }
    ]

    const shouldOpen = (e, link) => {
        if (!link) {
            e.preventDefault();
        }
    }

    const getButtonClass = (platform, link) => {
        if (!link) return 'btn-secondary';
        
        switch (platform) {
            case 'iOS':
                return 'btn-purple';
            case 'Desktop':
                return 'btn-primary';
            default:
                return 'btn-success';
        }
    }
</script>
